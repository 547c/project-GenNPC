extends "res://eval/rulebook_eval.gd"

const BIG_DATA_PATH := "res://eval/big_rulebook_v1.json"
const BIG_EMBED_PATH := "res://eval/embeddings_big_v1.json"
const BIG_SUMMARY_PATH := RESULTS_DIR + "/big_summary.md"
const BIG_HITS_PATH := RESULTS_DIR + "/big_rag_hits.md"
const BIG_SIZES := ["47", "66", "132", "264"]
const BIG_MODES := ["full", "word", "emb", "emb9"]
const RAG_MODES := ["word", "emb", "emb9"]
const EMBED_BATCH_LIMIT := 100
const DEFAULT_DAILY_LIMIT := 490
const RETRY_ALLOWANCE := 0.15
const RESET_HOUR := 2
const SERVER_ERROR_RETRIES := 3
const OLLAMA_NUM_PREDICT := 1024
const SCORE_PATHS := ["nocheck", "check", "reject_on_violation"]

var big: Dictionary = {}
var all_rules: Dictionary = {}
var big_conditions: Array = []
var damage_group: Array = []
var status_group: Array = []
var category_names: Array = []
var size_key := "66"
var mode := "full"
var gemini_calls := 0
var max_calls := -1
var schema_cache: Dictionary = {}
var num_ctx := OLLAMA_NUM_CTX


func _ready():
	_setup_regex()
	var code: int = await _big_main()
	print("GEMINI_CALLS=%d" % gemini_calls)
	get_tree().quit(code)


func _big_args() -> Dictionary:
	var out := {"provider": "gemini", "size": "66", "mode": "full", "runs": 3, "cards": [], "dryrun": false,
		"selfcheck": false, "fetch": false, "hit_table": false, "budget": false, "rescore": false, "no_summary": false, "num_ctx": OLLAMA_NUM_CTX, "daily_limit": DEFAULT_DAILY_LIMIT}
	var argv := OS.get_cmdline_user_args()
	for i in argv.size():
		var arg: String = argv[i]
		var next: String = argv[i + 1] if i + 1 < argv.size() else ""
		for key in ["provider", "size", "mode", "runs", "cards", "daily-limit", "num-ctx"]:
			var value := ""
			if arg == "--" + key and next != "":
				value = next
			elif arg.begins_with("--%s=" % key):
				value = arg.substr(key.length() + 3)
			if value == "":
				continue
			match key:
				"runs":
					out["runs"] = int(value)
				"daily-limit":
					out["daily_limit"] = int(value)
				"num-ctx":
					out["num_ctx"] = int(value)
				"cards":
					for part in value.split(",", false):
						out["cards"].append(part.strip_edges())
				_:
					out[key] = value
		match arg:
			"--dryrun":
				out["dryrun"] = true
			"--selfcheck":
				out["selfcheck"] = true
			"--fetch-embeddings":
				out["fetch"] = true
			"--hit-table":
				out["hit_table"] = true
			"--budget":
				out["budget"] = true
			"--rescore":
				out["rescore"] = true
			"--no-summary":
				out["no_summary"] = true
	return out


func _big_main() -> int:
	var args := _big_args()
	provider = args["provider"]
	size_key = args["size"]
	mode = args["mode"]
	num_ctx = args["num_ctx"]
	var runs: int = args["runs"]
	if (provider != "gemini" and provider != "ollama") or not BIG_SIZES.has(size_key) or not BIG_MODES.has(mode) or runs < 1:
		print("Usage: -- --provider gemini|ollama --size 47|66|132|264 --mode full|word|emb|emb9 [--runs N] [--cards A01,B02] [--dryrun] [--daily-limit 490] [--num-ctx 8192] [--no-summary] | --selfcheck | --fetch-embeddings | --hit-table | --budget | --rescore")
		return 1
	if not _load_big():
		return 1

	var problems := _self_check()
	if not problems.is_empty():
		print("SELF-CHECK FAILED (%d problems). Nothing was run." % problems.size())
		for p in problems:
			print("  " + p)
		return 3
	if args["selfcheck"]:
		return 0
	if args["budget"]:
		print("GEMINI_CALLS_SINCE_RESET=%d" % _usage_since_reset()["used"])
		return 0
	if args["hit_table"]:
		return _hit_table()
	if args["rescore"]:
		return _rescore_all()

	http = HTTPRequest.new()
	http.timeout = OLLAMA_TIMEOUT_SEC if provider == "ollama" else REQUEST_TIMEOUT_SEC
	add_child(http)

	if args["fetch"]:
		if provider != "gemini":
			print("Embedding fetches use the Gemini API. Run them without --provider ollama.")
			return 1
		_load_api_key()
		if api_key == "":
			push_error("API key is empty. Check the .env file.")
			return 1
		return await _fetch_big_embeddings()

	_use_size(size_key)
	if (mode == "emb" or mode == "emb9") and not _load_big_embeddings():
		return 1

	var cards: Array = []
	for card in big["tests"]:
		if args["cards"].is_empty() or args["cards"].has(card["id"]):
			cards.append(card)
	if cards.is_empty():
		print("No cards selected.")
		return 1

	if provider == "gemini":
		_load_api_key()
		if api_key == "":
			push_error("API key is empty. Check the .env file.")
			return 1
		var limit: int = args["daily_limit"]
		if limit > 0:
			var usage := _usage_since_reset()
			var planned := cards.size() * runs
			var ratio: float = maxf(RETRY_ALLOWANCE, usage["retry_ratio"] * 1.2)
			var allowance := ceili(planned * ratio)
			print("Gemini budget: used since the last reset %d, planned %d + retry allowance %d, limit %d" % [usage["used"], planned, allowance, limit])
			if usage["used"] + planned + allowance > limit:
				print("SKIPPED_BUDGET: this job could go over the daily limit of %d calls." % limit)
				return 4
			max_calls = limit - usage["used"]
	elif not await _check_ollama():
		return 1

	schema_cache = _schema()
	var started := _timestamp(false)
	print("=== Big rulebook eval: provider %s, model %s, size %s (%d rules), mode %s, runs %d, cards %d, num_ctx %d ===" % [provider, _model_name(), size_key, keywords.size(), mode, runs, cards.size(), num_ctx])

	var entries: Array = []
	for run in range(1, runs + 1):
		for card in cards:
			var entry: Dictionary = await _big_ask(card)
			entry["run"] = run
			entries.append(entry)
			_print_big_progress(entry)
			if aborted:
				break
		if aborted:
			break

	var stamp := _timestamp(true)
	if aborted:
		print("STOPPED: %s" % abort_message)
		_write_big_results(stamp, started, runs, cards.size(), entries, {}, "aborted_")
		return 2

	var summary := _big_summary(runs, entries)
	var prefix := "dryrun_" if args["dryrun"] else ""
	_print_big_table(runs, cards.size(), summary)
	var result_path := _write_big_results(stamp, started, runs, cards.size(), entries, summary, prefix)
	_write_big_review(result_path.trim_suffix(".json") + "_review.md", entries)
	if not args["dryrun"] and not args["no_summary"]:
		_rescore_all()
	return 0


func _load_big() -> bool:
	var file := FileAccess.open(BIG_DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("Cannot open " + BIG_DATA_PATH)
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid JSON in " + BIG_DATA_PATH)
		return false
	big = parsed
	all_rules = {}
	for r in big["rules"] + big["distractors"] + big.get("distractors_xl", []):
		all_rules[r["keyword"]] = r
	big_conditions = big["conditions"]
	damage_group = big["damage_group"]
	status_group = big["status_group"]
	category_names = []
	for t in big["tests"]:
		if not category_names.has(t["category"]):
			category_names.append(t["category"])
	rules_by_keyword = all_rules
	data = {"core_rules": big["core_rules"], "rules": [], "tests": big["tests"]}
	return true


func _use_size(s: String):
	var keys: Array = big["sizes"][s].duplicate()
	keys.sort()
	keywords = keys
	var rules: Array = []
	for k in keys:
		rules.append(all_rules[k])
	data["rules"] = rules


func _plain_effect(e: Dictionary) -> Dictionary:
	return {"keyword": e["keyword"], "n": null if e["n"] == null else int(e["n"]), "target": e["target"], "condition": e["condition"]}


func _plain_effects(list: Array) -> Array:
	var out: Array = []
	for e in list:
		out.append(_plain_effect(e))
	return out


func _normalize_effect(e) -> Dictionary:
	if typeof(e) != TYPE_DICTIONARY or not keywords.has(e.get("keyword")):
		return {}
	var n = e.get("n")
	var n_out = null
	if n != null:
		if not _is_whole_number(n):
			return {}
		n_out = int(n)
	var c = e.get("condition")
	if not TARGETS.has(e.get("target")) or (c != "NONE" and not big_conditions.has(c)):
		return {}
	return {"keyword": e["keyword"], "n": n_out, "target": e["target"], "condition": c}


func _schema() -> Dictionary:
	var conds: Array = ["NONE"]
	conds.append_array(big_conditions)
	return {
		"type": "OBJECT",
		"properties": {
			"reject": {"type": "BOOLEAN"},
			"reason": {"type": "STRING"},
			"effects": {
				"type": "ARRAY",
				"items": {
					"type": "OBJECT",
					"properties": {
						"keyword": {"type": "STRING", "enum": keywords},
						"n": {"type": "INTEGER", "nullable": true},
						"target": {"type": "STRING", "enum": TARGETS},
						"condition": {"type": "STRING", "enum": conds}
					},
					"required": ["keyword", "n", "target", "condition"]
				}
			},
			"cost": {"type": "INTEGER"}
		},
		"required": ["reject", "reason", "effects", "cost"]
	}


func _big_prompt(card_text: String, picked: Array) -> String:
	var quoted: Array = ["\"NONE\""]
	for c in big_conditions:
		quoted.append("\"%s\"" % c)
	var cond_list: String = ", ".join(PackedStringArray(quoted.slice(0, quoted.size() - 1))) + " or " + quoted[quoted.size() - 1]
	var p := "You turn a card description written by a player into card effects for a card game.\n\n"
	p += "Effect keywords: %s\n\n" % ", ".join(PackedStringArray(keywords))
	p += "Reply with a JSON object:\n"
	p += "- reject: true if the card cannot be made, otherwise false.\n"
	p += "- reason: a short reason.\n"
	p += "- effects: the list of effects. Each effect has keyword; n (a whole number, or null if the keyword has no n); target (\"self\", \"enemy\", \"all_enemies\" or \"none\"); condition (%s).\n" % cond_list
	p += "- cost: the total cost of the card, a whole number (use 0 if rejected).\n\n"
	p += "Turn the player's card text into these effects and decide its cost.\n"
	p += "\nRules of the game:\n"
	for rule_sentence in big["core_rules"]:
		p += "- %s\n" % rule_sentence
	p += "\nEffect rules:\n" if mode == "full" else "\nEffect rules (the ones most relevant to this card):\n"
	for r in picked:
		p += "- %s\n" % r["text"]
	p += "\nThe player's card: \"%s\"\n" % card_text
	return p


func _add_violation(out: Array, seen: Dictionary, code: String, message: String, rule_text: String):
	if seen.has(code):
		return
	seen[code] = true
	out.append({"code": code, "message": message, "rule_text": rule_text})


func _any_in(list: Array, group: Array) -> Array:
	var found: Array = []
	for k in list:
		if group.has(k) and not found.has(k):
			found.append(k)
	return found


func _validate(effects: Array) -> Array:
	var out: Array = []
	var seen := {}
	if effects.size() < 1 or effects.size() > MAX_EFFECTS:
		_add_violation(out, seen, "effect count", "A card must have 1 to %d effects, but your answer has %d." % [MAX_EFFECTS, effects.size()], big["core_rules"][0])
	var kws: Array = []
	for e in effects:
		kws.append(e["keyword"])
	for i in effects.size():
		var e: Dictionary = effects[i]
		var k: String = e["keyword"]
		var label := "Effect %d (%s)" % [i + 1, k]
		if not all_rules.has(k):
			_add_violation(out, seen, "unknown %s" % k, "%s is not a keyword in the rulebook." % label, big["core_rules"][1])
			continue
		var r: Dictionary = all_rules[k]
		var rt: String = r["text"]
		var family: String = r.get("variant_of", k)
		if family == "ECHO" or family == "CATALYST":
			if e["target"] != "none" or e["n"] != null:
				_add_violation(out, seen, "%s target/n" % k, "%s: target must be \"none\" and n must be null." % label, rt)
			if family == "ECHO" and e["condition"] != "NONE":
				_add_violation(out, seen, "%s condition" % k, "%s: condition must be NONE." % label, rt)
		else:
			if not r["targets"].has(e["target"]):
				_add_violation(out, seen, "%s target" % k, "%s: target \"%s\" is not allowed. Allowed targets: %s." % [label, e["target"], ", ".join(PackedStringArray(r["targets"]))], rt)
			if r["has_n"]:
				if e["n"] == null or e["n"] < r["n_min"] or e["n"] > r["n_max"]:
					_add_violation(out, seen, "%s n range" % k, "%s: n must be a whole number from %d to %d, but it is %s." % [label, r["n_min"], r["n_max"], "null" if e["n"] == null else str(e["n"])], rt)
			elif e["n"] != null:
				_add_violation(out, seen, "%s has no n" % k, "%s: this keyword has no n, so n must be null." % label, rt)
		if e["condition"] != "NONE" and not big_conditions.has(e["condition"]):
			_add_violation(out, seen, "%s bad condition" % k, "%s: \"%s\" is not a condition." % [label, e["condition"]], big["core_rules"][7])
		if r.get("forbid_condition", false) and e["condition"] != "NONE":
			_add_violation(out, seen, "%s forbids condition" % k, "%s: this keyword cannot have a condition." % label, rt)
		var required: Array = r.get("requires_condition", [])
		if not required.is_empty() and not required.has(e["condition"]):
			_add_violation(out, seen, "%s requires condition" % k, "%s: the condition must be %s." % [label, " or ".join(PackedStringArray(required))], rt)
		var others := kws.duplicate()
		others.remove_at(i)
		for nw in r.get("not_with", []):
			if others.has(nw):
				_add_violation(out, seen, "%s not with %s" % [k, nw], "%s cannot be on the same card as %s." % [label, nw], rt)
		if r.get("not_with_group", "") == "damage" and not _any_in(others, damage_group).is_empty():
			_add_violation(out, seen, "%s not with damage" % k, "%s cannot be on the same card as a damage effect (%s)." % [label, ", ".join(PackedStringArray(_any_in(others, damage_group)))], rt + " Damage effects: " + ", ".join(PackedStringArray(damage_group)) + ".")
		if r.get("requires_group", "") == "damage" and _any_in(others, damage_group).is_empty():
			_add_violation(out, seen, "%s needs damage" % k, "%s needs a damage effect on the same card." % label, rt + " Damage effects: " + ", ".join(PackedStringArray(damage_group)) + ".")
		if r.get("requires_group", "") == "status" and _any_in(others, status_group).is_empty():
			_add_violation(out, seen, "%s needs status" % k, "%s needs a status effect on the same card." % label, rt)
		var pos: String = r.get("position", "")
		if pos == "first" and i != 0:
			_add_violation(out, seen, "%s must be first" % k, "%s must be the first effect." % label, rt)
		if pos == "last" and i != effects.size() - 1:
			_add_violation(out, seen, "%s must be last" % k, "%s must be the last effect." % label, rt)
		if pos == "not_first" and i == 0:
			_add_violation(out, seen, "%s cannot be first" % k, "%s cannot be the first effect." % label, rt)
		if r.get("max_per_card", 0) > 0 and kws.count(k) > r["max_per_card"]:
			_add_violation(out, seen, "%s max per card" % k, "A card can have only %d %s." % [int(r["max_per_card"]), k], rt)
		if r.get("only_effect", false) and effects.size() > 1:
			_add_violation(out, seen, "%s must be only effect" % k, "%s must be the only effect on the card." % label, rt)
	return out


func _violation_codes(violations: Array) -> Array:
	var codes: Array = []
	for v in violations:
		codes.append(v["code"])
	codes.sort()
	return codes


func _effect_cost(effects: Array, i: int) -> int:
	var e: Dictionary = effects[i]
	if all_rules.get(e["keyword"], {}).get("variant_of", e["keyword"]) == "ECHO":
		return _effect_cost(effects, i - 1) if i > 0 else 0
	var r: Dictionary = all_rules[e["keyword"]]
	var c := int(r["cost_flat"])
	if r["has_n"]:
		c = ceili(r["cost_per_n"] * e["n"]) + int(r["cost_flat"])
	if e["target"] == "all_enemies" and not r.get("no_all_multiplier", false):
		c *= 2
	if e["condition"] != "NONE" and not r.get("no_condition_discount", false):
		c = ceili(c / 2.0)
	return c


func _card_cost(effects: Array) -> int:
	var total := 0
	for i in effects.size():
		total += _effect_cost(effects, i)
	return total


func _self_check() -> Array:
	var problems: Array = []
	var accepted_count := 0
	var illegal_count := 0
	for t in big["tests"]:
		for opt in t["accepted"]:
			accepted_count += 1
			var effects := _plain_effects(opt)
			var v := _validate(effects)
			if not v.is_empty():
				problems.append("%s accepted answer fails the check: %s" % [t["id"], ", ".join(PackedStringArray(_violation_codes(v)))])
			if t["cost"] == null or _card_cost(effects) != int(t["cost"]):
				problems.append("%s accepted answer costs %d, expected %s" % [t["id"], _card_cost(effects), str(t["cost"])])
		for ex in t["illegal_examples"]:
			illegal_count += 1
			var codes := _violation_codes(_validate(_plain_effects(ex["effects"])))
			var listed: Array = ex["errors"].duplicate()
			listed.sort()
			if codes.is_empty():
				problems.append("%s illegal example passes the check" % t["id"])
			elif codes != listed:
				problems.append("%s illegal example errors %s, data lists %s" % [t["id"], str(codes), str(listed)])
	if problems.is_empty():
		print("Self-check passed: %d accepted answers pass with matching cost, %d illegal examples are flagged (error lists match the data)." % [accepted_count, illegal_count])
	return problems


func _call_ollama(prompt: String, schema: Dictionary) -> Dictionary:
	var body := JSON.stringify({
		"model": OLLAMA_MODEL,
		"messages": [{"role": "user", "content": prompt}],
		"stream": false,
		"think": false,
		"format": _schema_for_ollama(schema),
		"options": {"temperature": 0, "seed": OLLAMA_SEED, "num_ctx": num_ctx, "num_predict": OLLAMA_NUM_PREDICT}
	})
	var started := Time.get_ticks_msec()
	var err := http.request(OLLAMA_URL, ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)
	if err != OK:
		return {"ok": false, "error": "request() failed: %d" % err, "api_ms": 0}
	var res = await http.request_completed
	var api_ms := Time.get_ticks_msec() - started
	var text_body: String = res[3].get_string_from_utf8()
	if res[0] != HTTPRequest.RESULT_SUCCESS:
		return {"ok": false, "error": "Network error (result %d)" % res[0], "api_ms": api_ms}
	if res[1] == 400 or res[1] == 404:
		aborted = true
		abort_message = "Ollama HTTP %d: %s" % [res[1], text_body.left(400)]
		return {"ok": false, "error": abort_message, "api_ms": api_ms}
	if res[1] != 200:
		return {"ok": false, "error": "Ollama HTTP %d: %s" % [res[1], text_body.left(300)], "api_ms": api_ms}
	var json = JSON.parse_string(text_body)
	if typeof(json) != TYPE_DICTIONARY or typeof(json.get("message")) != TYPE_DICTIONARY:
		return {"ok": false, "error": "Unparseable Ollama response: " + text_body.left(300), "api_ms": api_ms}
	var prompt_tokens: int = int(json.get("prompt_eval_count", 0))
	var output_tokens: int = int(json.get("eval_count", 0))
	var done_reason: String = str(json.get("done_reason", ""))
	var meta := {
		"prompt_tokens": prompt_tokens,
		"output_tokens": output_tokens,
		"done_reason": done_reason,
		"output_cut": done_reason == "length" or output_tokens >= OLLAMA_NUM_PREDICT,
		"truncated": done_reason == "length" or prompt_tokens + output_tokens >= num_ctx
	}
	return {"ok": true, "text": str(json["message"].get("content", "")), "api_ms": api_ms, "meta": meta}


func _model_call(prompt: String) -> Dictionary:
	var res := {}
	var waited_ms := 0
	for attempt in range(SERVER_ERROR_RETRIES + 1):
		if provider == "gemini":
			if max_calls >= 0 and gemini_calls >= max_calls:
				aborted = true
				abort_message = "Daily Gemini call limit reached (%d calls in this run)." % gemini_calls
				return {"ok": false, "error": abort_message, "api_ms": waited_ms}
			gemini_calls += 1
		res = await _call_gemini(prompt, schema_cache)
		res["api_ms"] += waited_ms
		var err := str(res.get("error", ""))
		if res["ok"] or aborted or not (err.begins_with("HTTP 5") or err.begins_with("Network error")) or attempt == SERVER_ERROR_RETRIES:
			break
		print("  %s. Waiting %ds (retry %d/%d)" % [err.left(40), int(RATE_LIMIT_WAIT_SEC), attempt + 1, SERVER_ERROR_RETRIES])
		waited_ms = res["api_ms"]
		await get_tree().create_timer(RATE_LIMIT_WAIT_SEC).timeout
	return res


func _new_path() -> Dictionary:
	return {"reject": null, "effects": null, "cost": null, "ai_cost": null, "reason": null, "correct": false, "effects_correct": null,
		"cost_correct": null, "wrong_reject": false, "wrong_pass": false, "error": null, "time_ms": 0}


func _pick_rules(card: Dictionary) -> Array:
	match mode:
		"word":
			return _retrieve_rules(card["text"])
		"emb":
			return _retrieve_rules_by_embedding(card["id"])
		"emb9":
			return _retrieve_rules_by_pieces(card["id"], true)
	return data["rules"]


func _big_ask(card: Dictionary) -> Dictionary:
	var picked := _pick_rules(card)
	var picked_keywords: Array = []
	for r in picked:
		picked_keywords.append(r["keyword"])
	var rag_hit = null
	if mode != "full" and not card["needed_rules"].is_empty():
		rag_hit = true
		for k in card["needed_rules"]:
			if not picked_keywords.has(k):
				rag_hit = false
	var accepted: Array = []
	for opt in card["accepted"]:
		accepted.append(_plain_effects(opt))
	var prompt := _big_prompt(card["text"], picked)
	var entry := {
		"id": card["id"],
		"tier": int(card["tier"]),
		"category": card["category"],
		"text": card["text"],
		"expected_reject": card["reject"],
		"accepted": accepted,
		"expected_cost": null if card["cost"] == null else int(card["cost"]),
		"needed_rules": card["needed_rules"],
		"rules_given": "all" if mode == "full" else picked_keywords,
		"rules_given_count": picked.size(),
		"rag_hit": rag_hit,
		"prompt_chars": prompt.length(),
		"first": {"output": null, "json_broken": false, "violations": [], "time_ms": 0, "llm_meta": null, "error": null},
		"nocheck": _new_path(),
		"check": _new_path(),
		"reject_on_violation": _new_path()
	}
	entry["check"].merge({"action": null, "retries": 0, "attempts": [], "json_broken_attempts": 0})
	entry["reject_on_violation"]["action"] = null

	var res: Dictionary = await _model_call(prompt)
	var first: Dictionary = entry["first"]
	first["time_ms"] = res["api_ms"]
	first["llm_meta"] = res.get("meta")
	if not res["ok"]:
		first["error"] = res["error"]
		entry["nocheck"]["error"] = res["error"]
		entry["check"]["error"] = res["error"]
		entry["reject_on_violation"]["error"] = res["error"]
		return entry

	var reply := _parse_reply(res["text"])
	var nc: Dictionary = entry["nocheck"]
	nc["time_ms"] = res["api_ms"]
	if reply.is_empty():
		first["json_broken"] = true
		nc["error"] = "Invalid JSON reply: " + str(res["text"]).left(200)
	else:
		first["output"] = reply
		nc["reason"] = reply["reason"]
		nc["reject"] = reply["reject"]
		nc["ai_cost"] = reply["cost"]
		if reply["reject"]:
			nc["effects"] = []
		else:
			nc["effects"] = reply["effects"]
			nc["cost"] = reply["cost"]
			first["violations"] = _violation_codes(_validate(reply["effects"]))
		_score_path(entry, nc)

	await _run_check(entry, prompt, reply, res)
	_score_path(entry, entry["check"])
	entry["reject_on_violation"] = _reject_path(entry)
	_score_path(entry, entry["reject_on_violation"])
	return entry


func _reject_path(entry: Dictionary) -> Dictionary:
	var p := _new_path()
	p["action"] = null
	var first: Dictionary = entry["first"]
	p["time_ms"] = first["time_ms"]
	if first["error"] != null:
		p["error"] = first["error"]
		return p
	var reply = first["output"]
	if reply == null:
		p["action"] = "code_reject"
		p["reason"] = "The first answer was not valid JSON for the required format."
		p["reject"] = true
		p["effects"] = []
		return p
	p["ai_cost"] = reply["cost"]
	if reply["reject"]:
		p["action"] = "ai_reject"
		p["reason"] = reply["reason"]
		p["reject"] = true
		p["effects"] = []
		return p
	var effects := _plain_effects(reply["effects"])
	var violations := _validate(effects)
	if violations.is_empty():
		p["action"] = "ok"
		p["reason"] = reply["reason"]
		p["reject"] = false
		p["effects"] = effects
		p["cost"] = _card_cost(effects)
		return p
	var messages: Array = []
	for v in violations:
		messages.append(v["message"])
	p["action"] = "code_reject"
	p["reason"] = "Rejected by the code on the first answer. Breaking: " + " ".join(PackedStringArray(messages))
	p["reject"] = true
	p["effects"] = []
	return p


func _run_check(entry: Dictionary, prompt: String, first_reply: Dictionary, first_res: Dictionary):
	var ck: Dictionary = entry["check"]
	var reply := first_reply
	var res := first_res
	var time_ms: int = first_res["api_ms"]
	var hint := ""
	var last: Array = []
	for attempt in range(MAX_REGENERATIONS + 1):
		if attempt > 0:
			res = await _model_call(prompt + hint)
			time_ms += res["api_ms"]
			if not res["ok"]:
				ck["error"] = res["error"]
				ck["time_ms"] = time_ms
				return
			reply = _parse_reply(res["text"])
		ck["retries"] = attempt
		var record := {"attempt": attempt, "prompt_chars": (prompt + hint).length(), "parse_ok": false, "output": null, "violations": [], "time_ms": res["api_ms"], "llm_meta": res.get("meta")}
		ck["attempts"].append(record)
		var violations: Array = []
		if reply.is_empty():
			ck["json_broken_attempts"] += 1
			violations = [{"code": "invalid json", "message": "The reply was not valid JSON for the required format.", "rule_text": ""}]
		else:
			record["parse_ok"] = true
			record["output"] = reply
			ck["ai_cost"] = reply["cost"]
			ck["reason"] = reply["reason"]
			if reply["reject"]:
				ck["action"] = "ai_reject"
				ck["reject"] = true
				ck["effects"] = []
				ck["time_ms"] = time_ms
				return
			violations = _validate(reply["effects"])
		for v in violations:
			record["violations"].append(v["message"])
		if violations.is_empty():
			ck["action"] = "ok"
			ck["reject"] = false
			ck["effects"] = reply["effects"]
			ck["cost"] = _card_cost(reply["effects"])
			ck["time_ms"] = time_ms
			return
		last = violations
		hint = _build_hint(violations)
	var messages: Array = []
	for v in last:
		messages.append(v["message"])
	ck["action"] = "code_reject"
	ck["reason"] = "Rejected by the code after %d attempts. Still breaking: %s" % [MAX_REGENERATIONS + 1, " ".join(PackedStringArray(messages))]
	ck["reject"] = true
	ck["effects"] = []
	ck["time_ms"] = time_ms


func _matches_accepted(effects: Array, accepted: Array) -> bool:
	if not _validate(effects).is_empty():
		return false
	var keys := _effect_keys(effects)
	for opt in accepted:
		if _effect_keys(opt) == keys:
			return true
	return false


func _score_path(entry: Dictionary, path: Dictionary):
	if path["error"] != null or path["reject"] == null:
		return
	if entry["expected_reject"]:
		path["correct"] = path["reject"]
		path["wrong_pass"] = not path["reject"]
		return
	if path["reject"]:
		path["wrong_reject"] = true
		path["effects_correct"] = false
		path["cost_correct"] = false
		return
	path["effects_correct"] = _matches_accepted(path["effects"], entry["accepted"])
	path["cost_correct"] = path["cost"] == entry["expected_cost"]
	path["correct"] = path["effects_correct"] and path["cost_correct"]


func _path_summary(runs: int, entries: Array, key: String) -> Dictionary:
	var per_run: Array = []
	for r in range(1, runs + 1):
		var correct := 0
		var valid := 0
		for e in entries:
			if e["run"] == r and e[key]["error"] == null:
				valid += 1
				if e[key]["correct"]:
					correct += 1
		per_run.append(_percent(correct, valid))
	var tier_total := {1: 0, 2: 0, 3: 0}
	var tier_correct := {1: 0, 2: 0, 3: 0}
	var cat_total := {}
	var cat_correct := {}
	for c in category_names:
		cat_total[c] = 0
		cat_correct[c] = 0
	var legal := 0
	var effects_ok := 0
	var cost_ok := 0
	var wrong_rejects := 0
	var wrong_passes := 0
	var errors := 0
	var times: Array = []
	for e in entries:
		var p: Dictionary = e[key]
		if p["error"] != null:
			errors += 1
			continue
		times.append(p["time_ms"])
		tier_total[e["tier"]] += 1
		cat_total[e["category"]] += 1
		if p["correct"]:
			tier_correct[e["tier"]] += 1
			cat_correct[e["category"]] += 1
		if p["wrong_reject"]:
			wrong_rejects += 1
		if p["wrong_pass"]:
			wrong_passes += 1
		if not e["expected_reject"]:
			legal += 1
			if p["effects_correct"]:
				effects_ok += 1
			if p["cost_correct"]:
				cost_ok += 1
	var tiers := {}
	for t in tier_total:
		tiers[str(t)] = null if tier_total[t] == 0 else _percent(tier_correct[t], tier_total[t])
	var cats := {}
	for c in category_names:
		cats[c] = null if cat_total[c] == 0 else _percent(cat_correct[c], cat_total[c])
	return {
		"per_run_accuracy": per_run,
		"avg_accuracy": _mean(per_run),
		"tier_accuracy": tiers,
		"category_accuracy": cats,
		"effects_accuracy": _percent(effects_ok, legal),
		"cost_accuracy": _percent(cost_ok, legal),
		"wrong_rejects": wrong_rejects,
		"wrong_passes": wrong_passes,
		"errors": errors,
		"avg_time_ms": _mean(times),
		"median_time_ms": _median(times)
	}


func _big_summary(runs: int, entries: Array) -> Dictionary:
	var rag_total := 0
	var rag_hits := 0
	var retries := 0
	var retried_cards := 0
	var fixed := 0
	var code_rejections := 0
	var reject_code_rejections := 0
	var first_broke_rules := 0
	var json_broken := 0
	var truncated := 0
	var output_cut := 0
	var max_prompt_tokens := 0
	for e in entries:
		if e["rag_hit"] != null:
			rag_total += 1
			if e["rag_hit"]:
				rag_hits += 1
		if e["first"]["json_broken"]:
			json_broken += 1
		if not e["first"]["violations"].is_empty():
			first_broke_rules += 1
		var ck: Dictionary = e["check"]
		retries += ck["retries"]
		if ck["retries"] > 0:
			retried_cards += 1
			if ck["correct"]:
				fixed += 1
		if ck["action"] == "code_reject":
			code_rejections += 1
		if e["reject_on_violation"]["action"] == "code_reject":
			reject_code_rejections += 1
		var metas: Array = [e["first"]["llm_meta"]]
		for a in ck["attempts"]:
			if a["attempt"] > 0:
				metas.append(a["llm_meta"])
		for m in metas:
			if m != null:
				if m["truncated"]:
					truncated += 1
				if m.get("output_cut", false):
					output_cut += 1
				max_prompt_tokens = maxi(max_prompt_tokens, m["prompt_tokens"])
	return {
		"nocheck": _path_summary(runs, entries, "nocheck"),
		"check": _path_summary(runs, entries, "check"),
		"reject_on_violation": _path_summary(runs, entries, "reject_on_violation"),
		"rag_hit_rate": null if rag_total == 0 else _percent(rag_hits, rag_total),
		"retries": retries,
		"retried_cards": retried_cards,
		"fixed_by_retry": fixed,
		"code_rejections": code_rejections,
		"reject_code_rejections": reject_code_rejections,
		"first_answers_breaking_rules": first_broke_rules,
		"json_broken": json_broken,
		"context_truncated": truncated,
		"output_cut": output_cut,
		"max_prompt_tokens": max_prompt_tokens,
		"gemini_calls": gemini_calls
	}


func _pct(v) -> String:
	return "n/a" if v == null else "%.1f" % v


func _nested_trio(s: Dictionary, group: String, name: String) -> String:
	var parts: Array = []
	for key in SCORE_PATHS:
		parts.append(_pct(s[key][group][name]))
	return " / ".join(PackedStringArray(parts))


func _flat_trio(s: Dictionary, name: String, fmt: String) -> String:
	var parts: Array = []
	for key in SCORE_PATHS:
		parts.append(fmt % s[key][name])
	return " / ".join(PackedStringArray(parts))


func _summary_columns() -> Array:
	var cols: Array = ["Time", "Provider", "Model", "Size", "Mode", "Runs", "Cards", "Accuracy no check (%)", "Accuracy retry (%)", "Accuracy reject (%)",
		"Per run no check (%)", "Per run retry (%)", "Per run reject (%)", "Tier 1 (%)", "Tier 2 (%)", "Tier 3 (%)"]
	for c in category_names:
		cols.append("%s (%%)" % c)
	cols.append_array(["Effects accuracy (%)", "Cost accuracy (%)", "Wrongly rejected", "Wrongly passed", "First answers breaking rules",
		"Retries", "Cards retried", "Fixed by retry", "Code rejections", "RAG hit rate (%)", "Avg time/card (ms)", "Broken JSON",
		"Output cut at limit", "Errors", "Gemini calls", "Results file"])
	return cols


func _summary_cells(runs: int, card_count: int, s: Dictionary, result_path: String, meta: Dictionary) -> Array:
	var cells: Array = [meta["time"], meta["provider"], meta["model"], meta["size"], meta["mode"], str(runs), str(card_count)]
	for key in SCORE_PATHS:
		cells.append("%.1f" % s[key]["avg_accuracy"])
	for key in SCORE_PATHS:
		var parts: Array = []
		for a in s[key]["per_run_accuracy"]:
			parts.append("%.1f" % a)
		cells.append(" / ".join(PackedStringArray(parts)))
	for t in ["1", "2", "3"]:
		cells.append(_nested_trio(s, "tier_accuracy", t))
	for c in category_names:
		cells.append(_nested_trio(s, "category_accuracy", c))
	cells.append(_flat_trio(s, "effects_accuracy", "%.1f"))
	cells.append(_flat_trio(s, "cost_accuracy", "%.1f"))
	cells.append(_flat_trio(s, "wrong_rejects", "%d"))
	cells.append(_flat_trio(s, "wrong_passes", "%d"))
	cells.append(str(s["first_answers_breaking_rules"]))
	cells.append(str(s["retries"]))
	cells.append(str(s["retried_cards"]))
	cells.append(str(s["fixed_by_retry"]))
	cells.append("- / %d / %d" % [s["code_rejections"], s["reject_code_rejections"]])
	cells.append(_pct(s["rag_hit_rate"]))
	cells.append(_flat_trio(s, "avg_time_ms", "%.0f"))
	cells.append(str(s["json_broken"]))
	cells.append(str(s["output_cut"]) if meta["provider"] == "ollama" else "n/a")
	cells.append(_flat_trio(s, "errors", "%d"))
	cells.append(str(s["gemini_calls"]))
	cells.append(result_path.get_file())
	return cells


func _live_meta() -> Dictionary:
	return {"time": _timestamp(false), "provider": provider, "model": _model_name(), "size": size_key, "mode": mode}


func _print_big_table(runs: int, card_count: int, s: Dictionary):
	var cols := _summary_columns()
	var cells := _summary_cells(runs, card_count, s, "", _live_meta())
	print("")
	for i in cols.size() - 1:
		print("  %-32s %s" % [cols[i], cells[i]])
	if provider == "ollama":
		print("  %-32s %d (max prompt tokens %d)" % ["Context truncated", s["context_truncated"], s["max_prompt_tokens"]])
	print("  (three numbers = no check / retry / reject)")
	print("")


func _write_big_summary(rows: Array):
	var file := FileAccess.open(BIG_SUMMARY_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write " + BIG_SUMMARY_PATH)
		return
	var cols := _summary_columns()
	var sep: Array = []
	for c in cols:
		sep.append("---")
	file.store_line("# Big Rulebook Eval Summary")
	file.store_line("")
	file.store_line("Each card gets one first answer from the AI. It is scored three ways. no check: the answer and the AI's cost as they are. retry: the code check (retry up to %d times with the broken rules, then the code rejects) and the cost comes from the code. reject: no second call; if the first answer breaks a rule the code rejects it, otherwise the code computes the cost. Cells with three numbers are \"no check / retry / reject\"." % MAX_REGENERATIONS)
	file.store_line("")
	file.store_line("An answer counts as correct when its effects match one accepted answer (in any order the rules allow) and the cost matches. Effects and cost accuracy are over cards that should not be rejected. Accuracy and time exclude cards that ended in an error. A first answer that is not valid JSON is an error in no check, and a code rejection in reject (and a failed attempt in retry). Time is model call time (retry includes the extra calls; reject uses the first call only); the 5s Gemini pacing waits are excluded.")
	file.store_line("")
	file.store_line("Modes: full = core rules + every rule of the size (alphabetical); word = word-overlap RAG (v3); emb = embedding RAG (v6); emb9 = embedding RAG with split pieces and condition pieces dropped (v9). RAG modes give the top %d rules of that size. Fixed by retry counts retried cards that ended correct. This file is rebuilt from the result files, so rerunning a job never leaves duplicate or half-written rows." % RAG_RULE_COUNT)
	file.store_line("")
	file.store_line("| " + " | ".join(PackedStringArray(cols)) + " |")
	file.store_line("| " + " | ".join(PackedStringArray(sep)) + " |")
	for cells in rows:
		file.store_line("| " + " | ".join(PackedStringArray(cells)) + " |")
	file.close()
	print("Wrote %s (%d rows)" % [BIG_SUMMARY_PATH, rows.size()])


func _intify(node):
	if typeof(node) == TYPE_FLOAT and node == floor(node) and absf(node) < 1e15:
		return int(node)
	if typeof(node) == TYPE_DICTIONARY:
		for k in node:
			node[k] = _intify(node[k])
	elif typeof(node) == TYPE_ARRAY:
		for i in node.size():
			node[i] = _intify(node[i])
	return node


func _rescore_file(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var doc = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(doc) != TYPE_DICTIONARY or not doc.get("complete", false) or typeof(doc.get("results")) != TYPE_ARRAY or doc["results"].is_empty():
		return {}
	for key in doc:
		if key != "summary":
			doc[key] = _intify(doc[key])
	var entries: Array = doc["results"]
	provider = doc["provider"]
	size_key = str(int(doc["size"]))
	mode = doc["mode"]
	if entries[0].has("reject_on_violation") and doc["summary"].has("reject_on_violation"):
		return doc
	for e in entries:
		e["reject_on_violation"] = _reject_path(e)
		_score_path(e, e["reject_on_violation"])
	var summary := _big_summary(int(doc["runs"]), entries)
	summary["gemini_calls"] = int(doc.get("gemini_calls", 0))
	doc["summary"] = summary
	var out := FileAccess.open(path, FileAccess.WRITE)
	if out == null:
		push_error("Cannot write " + path)
		return doc
	out.store_string(JSON.stringify(doc, "\t"))
	out.close()
	_write_big_review(path.trim_suffix(".json") + "_review.md", entries)
	print("Rescored " + path)
	return doc


func _rescore_all() -> int:
	var dir := DirAccess.open(RESULTS_DIR)
	if dir == null:
		return 1
	var names: Array = []
	for fname in dir.get_files():
		if fname.begins_with("big_") and fname.ends_with(".json"):
			names.append(fname)
	var rows: Array = []
	for fname in names:
		var path: String = RESULTS_DIR + "/" + fname
		var doc := _rescore_file(path)
		if doc.is_empty():
			continue
		var meta := {"time": doc["timestamp"], "provider": doc["provider"], "model": doc["model"], "size": str(int(doc["size"])), "mode": doc["mode"]}
		rows.append({"time": doc["timestamp"], "cells": _summary_cells(int(doc["runs"]), int(doc["card_count"]), doc["summary"], path, meta)})
	rows.sort_custom(func(a, b): return a["time"] < b["time"])
	var cell_rows: Array = []
	for r in rows:
		cell_rows.append(r["cells"])
	_write_big_summary(cell_rows)
	return 0


func _file_base(stamp: String, prefix: String) -> String:
	return "%s/%sbig_%s_%s_%s_%s" % [RESULTS_DIR, prefix, provider, size_key, mode, stamp]


func _write_big_results(stamp: String, started: String, runs: int, card_count: int, entries: Array, summary: Dictionary, prefix: String) -> String:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(RESULTS_DIR))
	var path := _file_base(stamp, prefix) + ".json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write " + path)
		return path
	file.store_string(JSON.stringify({
		"complete": not aborted,
		"abort_message": abort_message,
		"provider": provider,
		"model": _model_name(),
		"size": int(size_key),
		"rule_count": keywords.size(),
		"mode": mode,
		"runs": runs,
		"card_count": card_count,
		"started": started,
		"timestamp": _timestamp(false),
		"gemini_calls": gemini_calls,
		"num_ctx": num_ctx,
		"summary": summary,
		"results": entries
	}, "\t"))
	file.close()
	print("Saved " + path)
	return path


func _verdict(entry: Dictionary, p: Dictionary) -> String:
	if p["error"] != null:
		return "error: " + str(p["error"]).left(160)
	if p["correct"]:
		return "correct"
	if entry["expected_reject"]:
		return "should be rejected, but it was accepted"
	if p["reject"]:
		return "rejected, but the card can be made"
	var bits: Array = []
	if not p["effects_correct"]:
		bits.append("effects wrong")
	if not p["cost_correct"]:
		bits.append("cost %s, expected %s" % [str(p["cost"]), str(entry["expected_cost"])])
	return ", ".join(PackedStringArray(bits))


func _describe_answer(p: Dictionary) -> String:
	if p["reject"] == null:
		return "none"
	if p["reject"]:
		return "reject"
	return "%s cost %s" % [_describe_effects(p["effects"]), str(p["cost"])]


func _big_review_block(e: Dictionary) -> String:
	var nc: Dictionary = e["nocheck"]
	var ck: Dictionary = e["check"]
	var rv: Dictionary = e["reject_on_violation"]
	var b := "### %s (run %d, tier %d, %s)\n\n" % [e["id"], e["run"], e["tier"], e["category"]]
	b += "- Card: \"%s\"\n" % e["text"]
	b += "- Expected: %s\n" % _describe_expected(e)
	if mode != "full":
		b += "- Rules given: %s (needed: %s, hit: %s)\n" % [", ".join(PackedStringArray(e["rules_given"])), ", ".join(PackedStringArray(e["needed_rules"])), str(e["rag_hit"])]
	b += "- First answer: %s | AI cost %s\n" % [_describe_answer(nc), str(nc["ai_cost"])]
	if not e["first"]["violations"].is_empty():
		b += "- First answer breaks: %s\n" % ", ".join(PackedStringArray(e["first"]["violations"]))
	b += "- AI reason: %s\n" % str(nc["reason"])
	b += "- No check: %s\n" % _verdict(e, nc)
	for a in ck["attempts"]:
		if a["attempt"] == 0:
			continue
		var out_text := "no output"
		if a["output"] != null:
			out_text = "reject" if a["output"]["reject"] else _describe_effects(a["output"]["effects"])
		var check_text := "passed" if a["violations"].is_empty() else " / ".join(PackedStringArray(a["violations"]))
		if a["output"] != null and a["output"]["reject"]:
			check_text = "not run (AI rejected)"
		b += "- Retry %d: %s | code check: %s\n" % [a["attempt"], out_text, check_text]
	b += "- Retry check: %s -> %s (%s)\n" % [_describe_answer(ck), _verdict(e, ck), str(ck["action"])]
	if ck["action"] == "code_reject":
		b += "- Code reason: %s\n" % str(ck["reason"])
	b += "- Reject on violation: %s -> %s (%s)\n" % [_describe_answer(rv), _verdict(e, rv), str(rv["action"])]
	if rv["action"] == "code_reject":
		b += "- Code reason: %s\n" % str(rv["reason"])
	b += "\n"
	return b


func _write_big_review(path: String, entries: Array):
	var all_wrong: Array = []
	var some_wrong: Array = []
	for e in entries:
		var wrong := 0
		for key in SCORE_PATHS:
			if not e[key]["correct"]:
				wrong += 1
		if wrong == SCORE_PATHS.size():
			all_wrong.append(e)
		elif wrong > 0:
			some_wrong.append(e)
	var out := "# Big rulebook review: %s %s, size %s, mode %s\n\n" % [provider, _model_name(), size_key, mode]
	out += "Every card that was wrong in at least one of the three scorings (no check, retry, reject on violation); errors count as wrong. The lines of each card show all three.\n\n"
	for group in [["Wrong in all three", all_wrong], ["Wrong in some of the three", some_wrong]]:
		out += "## %s (%d)\n\n" % [group[0], group[1].size()]
		for e in group[1]:
			out += _big_review_block(e)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write " + path)
		return
	file.store_string(out)
	file.close()
	print("Saved " + path)


func _print_big_progress(e: Dictionary):
	var nc: Dictionary = e["nocheck"]
	var ck: Dictionary = e["check"]
	var rv: Dictionary = e["reject_on_violation"]
	var extras := ""
	if ck["retries"] > 0:
		extras += " retries=%d" % ck["retries"]
	if ck["action"] == "code_reject":
		extras += " CODE_REJECT"
	if rv["action"] == "code_reject":
		extras += " FIRST_REJECT"
	if e["first"]["error"] != null:
		extras += " ERROR=" + str(e["first"]["error"]).left(120)
	elif ck["error"] != null:
		extras += " CHECK_ERROR=" + str(ck["error"]).left(120)
	print("[r%d] %s (%s) first=%s | no check %s | retry %s %s | reject %s %s | %dms%s" % [e["run"], e["id"], e["category"], _describe_answer(nc),
		"OK" if nc["correct"] else "WRONG", _describe_answer(ck), "OK" if ck["correct"] else "WRONG", _describe_answer(rv),
		"OK" if rv["correct"] else "WRONG", ck["time_ms"], extras])


func _embed_chunked(texts: Array, task: String, counter: Dictionary) -> Dictionary:
	var vectors: Array = []
	var start := 0
	while start < texts.size():
		if counter["calls"] > 0:
			await get_tree().create_timer(CALL_GAP_SEC).timeout
		var chunk := texts.slice(start, start + EMBED_BATCH_LIMIT)
		counter["calls"] += 1
		var res: Dictionary = await _embed_batch(chunk, task)
		if not res["ok"]:
			return res
		vectors.append_array(res["vectors"])
		start += EMBED_BATCH_LIMIT
	return {"ok": true, "vectors": vectors}


func _piece_texts() -> Dictionary:
	var pieces := {}
	for card in big["tests"]:
		pieces[card["id"]] = _split_card(card["text"])
	return pieces


func _add_missing_embeddings() -> int:
	var file := FileAccess.open(BIG_EMBED_PATH, FileAccess.READ)
	var cached = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(cached) != TYPE_DICTIONARY:
		print("%s is not valid JSON. Delete it and fetch again." % BIG_EMBED_PATH)
		return 1
	var missing: Array = []
	for k in all_rules:
		if not cached["rules"].has(k):
			missing.append(k)
		elif cached["rule_texts"][k] != all_rules[k]["text"]:
			print("%s has an old text for the rule %s. Delete it and fetch again." % [BIG_EMBED_PATH, k])
			return 1
	if missing.is_empty():
		if _load_big_embeddings():
			print("%s already exists and matches the data. Not calling the embedding API again." % BIG_EMBED_PATH)
			return 0
		print("%s exists but does not match the data. Delete it and fetch again." % BIG_EMBED_PATH)
		return 1
	missing.sort()
	var docs: Array = []
	for k in missing:
		docs.append(all_rules[k]["text"])
	var counter := {"calls": 0}
	var res: Dictionary = await _embed_chunked(docs, "RETRIEVAL_DOCUMENT", counter)
	if not res["ok"]:
		print("Embedding request failed: %s" % res["error"])
		return 2
	var dims := int(cached["dimensions"])
	for vec in res["vectors"]:
		if vec.size() != dims:
			print("Embedding sizes differ: %d vs %d" % [vec.size(), dims])
			return 2
	for i in missing.size():
		cached["rule_texts"][missing[i]] = docs[i]
		cached["rules"][missing[i]] = res["vectors"][i]
	cached["dimensions"] = dims
	cached["fetch_log"] = _intify(cached["fetch_log"])
	cached["fetch_log"].append({"time": _timestamp(false), "calls": counter["calls"], "added_rules": missing.size()})
	var tmp_path := BIG_EMBED_PATH + ".tmp"
	var out := FileAccess.open(tmp_path, FileAccess.WRITE)
	if out == null:
		push_error("Cannot write " + tmp_path)
		return 1
	out.store_string(JSON.stringify(cached, "", false, true))
	out.close()
	DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp_path), ProjectSettings.globalize_path(BIG_EMBED_PATH))
	print("Added %d rules to %s (%d embedding calls)." % [missing.size(), BIG_EMBED_PATH, counter["calls"]])
	return 0


func _fetch_big_embeddings() -> int:
	if FileAccess.file_exists(BIG_EMBED_PATH):
		return await _add_missing_embeddings()
	var rule_keys: Array = all_rules.keys()
	rule_keys.sort()
	var cond_keys: Array = big_conditions.duplicate()
	var docs: Array = []
	for k in rule_keys:
		docs.append(all_rules[k]["text"])
	for k in cond_keys:
		docs.append(big["condition_phrases"][k])
	var card_ids: Array = []
	var queries: Array = []
	for card in big["tests"]:
		card_ids.append(card["id"])
		queries.append(card["text"])
	var pieces := _piece_texts()
	var piece_list: Array = []
	for id in pieces:
		if pieces[id].size() > 1:
			for t in pieces[id]:
				if not piece_list.has(t):
					piece_list.append(t)
	queries.append_array(piece_list)

	var counter := {"calls": 0}
	var doc_res: Dictionary = await _embed_chunked(docs, "RETRIEVAL_DOCUMENT", counter)
	if not doc_res["ok"]:
		print("Embedding request failed: %s" % doc_res["error"])
		return 2
	var query_res: Dictionary = await _embed_chunked(queries, "RETRIEVAL_QUERY", counter)
	if not query_res["ok"]:
		print("Embedding request failed: %s" % query_res["error"])
		return 2
	var dims: int = doc_res["vectors"][0].size()
	for vec in doc_res["vectors"] + query_res["vectors"]:
		if vec.size() != dims:
			print("Embedding sizes differ: %d vs %d" % [vec.size(), dims])
			return 2

	var out := {
		"model": EMBED_MODEL,
		"dimensions": dims,
		"fetched_at": _timestamp(false),
		"fetch_log": [{"time": _timestamp(false), "calls": counter["calls"]}],
		"task_types": {"rules": "RETRIEVAL_DOCUMENT", "conditions": "RETRIEVAL_DOCUMENT", "cards": "RETRIEVAL_QUERY", "pieces": "RETRIEVAL_QUERY"},
		"rule_texts": {}, "rules": {}, "card_texts": {}, "cards": {}, "pieces": {}, "conditions": {}
	}
	for i in rule_keys.size():
		out["rule_texts"][rule_keys[i]] = docs[i]
		out["rules"][rule_keys[i]] = doc_res["vectors"][i]
	for i in cond_keys.size():
		out["conditions"][cond_keys[i]] = {"text": docs[rule_keys.size() + i], "vector": doc_res["vectors"][rule_keys.size() + i]}
	for i in card_ids.size():
		out["card_texts"][card_ids[i]] = queries[i]
		out["cards"][card_ids[i]] = query_res["vectors"][i]
	for id in pieces:
		var vecs: Array = []
		if pieces[id].size() > 1:
			for t in pieces[id]:
				vecs.append(query_res["vectors"][card_ids.size() + piece_list.find(t)])
		out["pieces"][id] = {"texts": pieces[id], "vectors": vecs}
	var file := FileAccess.open(BIG_EMBED_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write " + BIG_EMBED_PATH)
		return 1
	file.store_string(JSON.stringify(out, "", false, true))
	file.close()
	print("Saved %s: %d rules, %d conditions, %d cards, %d pieces, %d dimensions, %d embedding calls." % [BIG_EMBED_PATH, rule_keys.size(), cond_keys.size(), card_ids.size(), piece_list.size(), dims, counter["calls"]])
	return 0


func _load_big_embeddings() -> bool:
	var file := FileAccess.open(BIG_EMBED_PATH, FileAccess.READ)
	if file == null:
		push_error("%s not found. Run --fetch-embeddings first." % BIG_EMBED_PATH)
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid JSON in " + BIG_EMBED_PATH)
		return false
	embeddings = parsed
	rule_vectors = {}
	for k in all_rules:
		if not embeddings["rules"].has(k) or embeddings["rule_texts"][k] != all_rules[k]["text"]:
			push_error("Embedding file does not match the rule %s. Delete it and fetch again." % k)
			return false
		rule_vectors[k] = _normalized(embeddings["rules"][k])
	condition_vectors = {}
	for k in big_conditions:
		var entry = embeddings["conditions"].get(k)
		if entry == null or entry["text"] != big["condition_phrases"][k]:
			push_error("Embedding file does not match the condition %s. Delete it and fetch again." % k)
			return false
		condition_vectors[k] = _normalized(entry["vector"])
	var pieces := _piece_texts()
	for card in big["tests"]:
		var id: String = card["id"]
		if not embeddings["cards"].has(id) or embeddings["card_texts"][id] != card["text"]:
			push_error("Embedding file does not match the card %s. Delete it and fetch again." % id)
			return false
		var entry = embeddings["pieces"].get(id)
		if entry == null or entry["texts"] != pieces[id] or (pieces[id].size() > 1 and entry["vectors"].size() != pieces[id].size()):
			push_error("Piece embeddings do not match card %s. Delete the file and fetch again." % id)
			return false
	return true


func _hit_table() -> int:
	if not _load_big_embeddings():
		return 1
	var cols: Array = ["Size", "Rules"]
	for m in RAG_MODES:
		cols.append("%s hit rate (%%)" % m)
	var lines: Array = []
	lines.append("| " + " | ".join(PackedStringArray(cols)) + " |")
	var sep: Array = []
	for c in cols:
		sep.append("---")
	lines.append("| " + " | ".join(PackedStringArray(sep)) + " |")
	var misses := {}
	var counted := 0
	for s in BIG_SIZES:
		_use_size(s)
		var cells: Array = [s, str(keywords.size())]
		for m in RAG_MODES:
			mode = m
			var hits := 0
			var total := 0
			misses["%s %s" % [s, m]] = []
			for card in big["tests"]:
				if card["needed_rules"].is_empty():
					continue
				total += 1
				var got: Array = []
				for r in _pick_rules(card):
					got.append(r["keyword"])
				var ok := true
				for k in card["needed_rules"]:
					if not got.has(k):
						ok = false
				if ok:
					hits += 1
				else:
					misses["%s %s" % [s, m]].append(card["id"])
			counted = total
			cells.append("%.1f (%d/%d)" % [_percent(hits, total), hits, total])
		lines.append("| " + " | ".join(PackedStringArray(cells)) + " |")
	var out := "# Big rulebook RAG hit rate\n\nWritten %s. No API calls (cached embeddings). A hit means every needed rule of the card is among the top %d picked rules. %d cards have needed rules (A20 has none and is left out).\n\n" % [_timestamp(false), RAG_RULE_COUNT, counted]
	out += "\n".join(PackedStringArray(lines)) + "\n\n## Missed cards\n\n"
	for key in misses:
		out += "- %s: %s\n" % [key, ", ".join(PackedStringArray(misses[key]))]
	print(out)
	var file := FileAccess.open(BIG_HITS_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write " + BIG_HITS_PATH)
		return 1
	file.store_string(out)
	file.close()
	print("Saved " + BIG_HITS_PATH)
	return 0


func _pseudo_unix(stamp: String) -> int:
	return Time.get_unix_time_from_datetime_string(stamp.replace(" ", "T"))


func _usage_since_reset() -> Dictionary:
	var now := _pseudo_unix(_timestamp(false))
	var boundary := now - posmod(now, 86400) + RESET_HOUR * 3600
	if now < boundary:
		boundary -= 86400
	var used := 0
	var retry_ratio := 0.0
	for dir_path in [RESULTS_DIR, "res://eval"]:
		var dir := DirAccess.open(dir_path)
		if dir == null:
			continue
		for fname in dir.get_files():
			if not fname.ends_with(".json"):
				continue
			if dir_path == "res://eval" and not fname.begins_with("embeddings_"):
				continue
			var file := FileAccess.open(dir_path + "/" + fname, FileAccess.READ)
			if file == null:
				continue
			var doc = JSON.parse_string(file.get_as_text())
			file.close()
			if typeof(doc) != TYPE_DICTIONARY:
				continue
			if fname.begins_with("embeddings_"):
				for item in doc.get("fetch_log", []):
					if _pseudo_unix(item["time"]) >= boundary:
						used += int(item["calls"])
				continue
			if doc.get("provider", "gemini") == "ollama" or not doc.has("timestamp"):
				continue
			if doc.get("complete", false) and doc.has("gemini_calls") and not fname.begins_with("dryrun_") and doc["results"].size() >= 30:
				retry_ratio = maxf(retry_ratio, float(int(doc["gemini_calls"]) - doc["results"].size()) / doc["results"].size())
			if _pseudo_unix(doc["timestamp"]) < boundary:
				continue
			if doc.has("gemini_calls"):
				used += int(doc["gemini_calls"])
				continue
			for r in doc.get("results", []):
				var attempts: Array = r.get("attempts", [])
				var n := attempts.size() if not attempts.is_empty() else 1
				if r.get("error") != null and not attempts.is_empty():
					n += 1
				used += n
	return {"used": used, "retry_ratio": retry_ratio}
