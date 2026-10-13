extends Node

const MODEL := "gemini-3.5-flash-lite"
const URL := "https://generativelanguage.googleapis.com/v1beta/models/" + MODEL + ":generateContent"
const DATA_PATH := "res://eval/card_rulebook_data.json"
const RESULTS_DIR := "res://eval/results"
const CALL_GAP_SEC := 5.0
const RATE_LIMIT_WAIT_SEC := 30.0
const MAX_RATE_LIMIT_RETRIES := 3
const MAX_REGENERATIONS := 2
const REQUEST_TIMEOUT_SEC := 90.0
const MAX_EFFECTS := 3
const RAG_RULE_COUNT := 5

const TARGETS := ["self", "enemy", "all_enemies", "none"]
const CONDITIONS := ["NONE", "IF_ENEMY_BURNING", "IF_ENEMY_CHILLED", "IF_MY_HP_BELOW_HALF", "IF_ENEMY_HP_BELOW_HALF", "IF_FIRST_CARD"]
const CATEGORIES := ["direct", "paraphrase", "confusing", "condition", "illegal", "trick"]
const STOPWORDS := ["a", "an", "the", "was", "were", "is", "are", "did", "do", "does", "you", "i", "it", "at", "in", "on", "of", "to", "that", "who", "what", "me", "my", "your", "around", "just", "tell", "deal", "damage", "enemy", "enemies", "n", "turn", "turns", "cost", "target"]
const VERSION_NAMES := {1: "AI only", 2: "AI + all rules", 3: "AI + RAG rules", 4: "AI + RAG rules + code check", 5: "AI + all rules + code check"}
const TABLE_COLUMNS := ["Version", "Runs", "Accuracy per run (%)", "Avg accuracy (%)", "Direct (%)", "Paraphrase (%)", "Confusing (%)", "Condition (%)", "Illegal (%)", "Trick (%)", "Effects accuracy (%)", "Cost accuracy (%)", "Wrongly rejected", "Wrongly passed", "RAG hit rate (%)", "Regenerations", "Code rejections", "Avg time/card (ms)", "Median time/card (ms)", "Errors"]

var api_key := ""
var data: Dictionary = {}
var keywords: Array = []
var rules_by_keyword: Dictionary = {}
var http: HTTPRequest
var punct_re := RegEx.new()
var digit_letter_re := RegEx.new()
var letter_digit_re := RegEx.new()
var first_call := true
var aborted := false
var abort_message := ""
var summary_path := RESULTS_DIR + "/rulebook_summary.md"


func _ready():
	_setup_regex()
	var code: int = await _main()
	get_tree().quit(code)


func _setup_regex():
	punct_re.compile("[^a-z0-9\\s]")
	digit_letter_re.compile("([0-9])([a-z])")
	letter_digit_re.compile("([a-z])([0-9])")


func _main() -> int:
	var args := _parse_args()
	var version: int = args["version"]
	var runs: int = args["runs"]
	var dryrun: bool = args["dryrun"]
	var only_ids: Array = args["cards"]
	if version < 1 or version > 5 or runs < 1:
		print("Usage: -- --version=1..5 [--runs=R] [--cards=T1,P1] [--dryrun]")
		return 1

	_load_api_key()
	if api_key == "":
		push_error("API key is empty. Check the .env file.")
		return 1
	if not _load_data():
		return 1

	http = HTTPRequest.new()
	http.timeout = REQUEST_TIMEOUT_SEC
	add_child(http)

	var cards: Array = []
	for card in data["tests"]:
		if only_ids.is_empty() or only_ids.has(card["id"]):
			cards.append(card)
	if cards.is_empty():
		print("No cards selected.")
		return 1

	print("=== Rulebook eval: version %d (%s), runs %d, cards %d, model %s ===" % [version, VERSION_NAMES[version], runs, cards.size(), MODEL])

	var entries: Array = []
	for run in range(1, runs + 1):
		for card in cards:
			var entry: Dictionary = await _ask(version, card)
			entry["run"] = run
			entries.append(entry)
			_print_progress(version, run, entry)
			if aborted:
				break
		if aborted:
			break

	if aborted:
		print("STOPPED: %s" % abort_message)
		print("responseSchema was kept in the request; nothing was removed. Fix the schema/request and rerun.")
		return 2

	var summary := _summarize(runs, entries)
	var stamp := _timestamp(true)
	_print_table(version, runs, summary)
	_write_results(version, runs, stamp, entries, summary, dryrun)
	_write_review(version, entries, dryrun)
	if not dryrun:
		_append_summary_md(version, runs, summary)
	return 0


func _parse_args() -> Dictionary:
	var out := {"version": 0, "runs": 3, "cards": [], "dryrun": false}
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--version="):
			out["version"] = int(arg.substr("--version=".length()))
		elif arg.begins_with("--runs="):
			out["runs"] = int(arg.substr("--runs=".length()))
		elif arg.begins_with("--cards="):
			for part in arg.substr("--cards=".length()).split(",", false):
				out["cards"].append(part.strip_edges())
		elif arg == "--dryrun":
			out["dryrun"] = true
	return out


func _load_api_key():
	var file := FileAccess.open("res://.env", FileAccess.READ)
	if file == null:
		push_error(".env file not found. Make sure it's in the project root.")
		return
	while not file.eof_reached():
		var line := file.get_line()
		if line.begins_with("GEMINI_API_KEY="):
			api_key = line.substr("GEMINI_API_KEY=".length()).strip_edges()
	file.close()


func _load_data() -> bool:
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("Cannot open " + DATA_PATH)
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Invalid JSON in " + DATA_PATH)
		return false
	data = parsed
	keywords = []
	rules_by_keyword = {}
	for rule in data["rules"]:
		keywords.append(rule["keyword"])
		rules_by_keyword[rule["keyword"]] = rule
	return true


func _schema() -> Dictionary:
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
						"condition": {"type": "STRING", "enum": CONDITIONS}
					},
					"required": ["keyword", "n", "target", "condition"]
				}
			},
			"cost": {"type": "INTEGER"}
		},
		"required": ["reject", "reason", "effects", "cost"]
	}


func _call_gemini(prompt: String, schema: Dictionary) -> Dictionary:
	var body := JSON.stringify({
		"contents": [{"parts": [{"text": prompt}]}],
		"generationConfig": {
			"temperature": 0,
			"responseMimeType": "application/json",
			"responseSchema": schema
		}
	})
	var headers := ["Content-Type: application/json", "x-goog-api-key: " + api_key]
	var api_ms := 0
	var rate_limit_retries := 0
	var skip_gap := first_call
	first_call = false

	while true:
		if not skip_gap:
			await get_tree().create_timer(CALL_GAP_SEC).timeout
		skip_gap = false

		var started := Time.get_ticks_msec()
		var err := http.request(URL, headers, HTTPClient.METHOD_POST, body)
		if err != OK:
			return {"ok": false, "error": "request() failed: %d" % err, "api_ms": api_ms}
		var res = await http.request_completed
		api_ms += Time.get_ticks_msec() - started

		var result: int = res[0]
		var code: int = res[1]
		var text_body: String = res[3].get_string_from_utf8()

		if result != HTTPRequest.RESULT_SUCCESS:
			return {"ok": false, "error": "Network error (result %d)" % result, "api_ms": api_ms}
		if code == 429 and rate_limit_retries < MAX_RATE_LIMIT_RETRIES:
			rate_limit_retries += 1
			print("  429 rate limited. Waiting %ds (retry %d/%d)" % [int(RATE_LIMIT_WAIT_SEC), rate_limit_retries, MAX_RATE_LIMIT_RETRIES])
			await get_tree().create_timer(RATE_LIMIT_WAIT_SEC).timeout
			skip_gap = true
			continue
		if code == 429:
			aborted = true
			abort_message = "HTTP 429 persisted after %d retries (possibly the daily free quota): %s" % [MAX_RATE_LIMIT_RETRIES, text_body.left(300)]
			return {"ok": false, "error": abort_message, "api_ms": api_ms}
		if code == 400:
			aborted = true
			abort_message = "HTTP 400: " + text_body
			return {"ok": false, "error": abort_message, "api_ms": api_ms}
		if code != 200:
			return {"ok": false, "error": "HTTP %d: %s" % [code, text_body.left(300)], "api_ms": api_ms}

		var json = JSON.parse_string(text_body)
		if typeof(json) != TYPE_DICTIONARY:
			return {"ok": false, "error": "Unparseable response: " + text_body.left(300), "api_ms": api_ms}
		var candidates: Array = json.get("candidates", [])
		if candidates.is_empty() or not candidates[0].has("content"):
			return {"ok": false, "error": "No content in response: " + text_body.left(300), "api_ms": api_ms}
		var text := ""
		for part in candidates[0]["content"].get("parts", []):
			if part.has("text") and not part.get("thought", false):
				text += part["text"]
		return {"ok": true, "text": text, "api_ms": api_ms}

	return {"ok": false, "error": "unreachable", "api_ms": api_ms}


func _is_whole_number(v) -> bool:
	return (typeof(v) == TYPE_FLOAT or typeof(v) == TYPE_INT) and v == floor(v)


func _normalize_effect(e) -> Dictionary:
	if typeof(e) != TYPE_DICTIONARY:
		return {}
	if not keywords.has(e.get("keyword")):
		return {}
	var n = e.get("n")
	var n_out = null
	if n != null:
		if not _is_whole_number(n):
			return {}
		n_out = int(n)
	if not TARGETS.has(e.get("target")) or not CONDITIONS.has(e.get("condition")):
		return {}
	return {"keyword": e["keyword"], "n": n_out, "target": e["target"], "condition": e["condition"]}


func _normalize_effects(raw: Array) -> Array:
	var out: Array = []
	for e in raw:
		out.append(_normalize_effect(e))
	return out


func _parse_reply(text: String) -> Dictionary:
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	if typeof(parsed.get("reject")) != TYPE_BOOL or typeof(parsed.get("reason")) != TYPE_STRING:
		return {}
	if typeof(parsed.get("effects")) != TYPE_ARRAY or not _is_whole_number(parsed.get("cost")):
		return {}
	var effects: Array = []
	for e in parsed["effects"]:
		var norm := _normalize_effect(e)
		if norm.is_empty():
			return {}
		effects.append(norm)
	return {"reject": parsed["reject"], "reason": parsed["reason"], "effects": effects, "cost": int(parsed["cost"])}


func _calc_cost(effects: Array) -> int:
	var total := 0
	var prev := 0
	for e in effects:
		var rule: Dictionary = rules_by_keyword[e["keyword"]]
		var c := 0
		if rule.get("special", "") == "echo":
			c = prev
		else:
			if rule["has_n"]:
				c = ceili(rule["cost_per_n"] * e["n"]) + int(rule["cost_flat"])
			else:
				c = int(rule["cost_flat"])
			if e["target"] == "all_enemies":
				c *= 2
			if e["condition"] != "NONE":
				c = ceili(c / 2.0)
		total += c
		prev = c
	return total


func _check_card(effects: Array) -> Array:
	var violations: Array = []
	if effects.size() < 1 or effects.size() > MAX_EFFECTS:
		violations.append({"message": "A card must have 1 to %d effects, but your answer has %d." % [MAX_EFFECTS, effects.size()], "rule_text": data["core_rules"][0]})
	var echo_count := 0
	for i in effects.size():
		var e: Dictionary = effects[i]
		var rule: Dictionary = rules_by_keyword[e["keyword"]]
		var label := "Effect %d (%s)" % [i + 1, e["keyword"]]
		var rule_text: String = rule["text"]
		if rule.get("special", "") == "echo":
			echo_count += 1
			if i == 0:
				violations.append({"message": "%s cannot be the first effect." % label, "rule_text": rule_text})
			if echo_count > 1:
				violations.append({"message": "%s: a card can have only one ECHO." % label, "rule_text": rule_text})
			if e["n"] != null:
				violations.append({"message": "%s: n must be null." % label, "rule_text": rule_text})
			if e["target"] != "none":
				violations.append({"message": "%s: target must be \"none\"." % label, "rule_text": rule_text})
			if e["condition"] != "NONE":
				violations.append({"message": "%s: condition must be NONE." % label, "rule_text": rule_text})
			continue
		if rule["has_n"]:
			if e["n"] == null:
				violations.append({"message": "%s: n must be a whole number from %d to %d, but it is null." % [label, rule["n_min"], rule["n_max"]], "rule_text": rule_text})
			elif e["n"] < rule["n_min"] or e["n"] > rule["n_max"]:
				violations.append({"message": "%s: n=%d is outside the allowed range %d to %d." % [label, e["n"], rule["n_min"], rule["n_max"]], "rule_text": rule_text})
		elif e["n"] != null:
			violations.append({"message": "%s: this keyword has no n, so n must be null." % label, "rule_text": rule_text})
		if not rule["targets"].has(e["target"]):
			violations.append({"message": "%s: target \"%s\" is not allowed. Allowed targets: %s." % [label, e["target"], ", ".join(PackedStringArray(rule["targets"]))], "rule_text": rule_text})
	return violations


func _build_hint(violations: Array) -> String:
	var h := "\n\nYour answer breaks these rules:\n"
	for v in violations:
		h += "- " + v["message"]
		if v["rule_text"] != "":
			h += " Rule: " + v["rule_text"]
		h += "\n"
	h += "If the card really asks for something the rules don't allow, set reject to true. Otherwise fix your answer."
	return h


func _build_prompt(version: int, card_text: String, picked: Array) -> String:
	var p := "You turn a card description written by a player into card effects for a card game.\n\n"
	p += "Effect keywords: %s\n\n" % ", ".join(PackedStringArray(keywords))
	p += "Reply with a JSON object:\n"
	p += "- reject: true if the card cannot be made, otherwise false.\n"
	p += "- reason: a short reason.\n"
	p += "- effects: the list of effects. Each effect has keyword; n (a whole number, or null if the keyword has no n); target (\"self\", \"enemy\", \"all_enemies\" or \"none\"); condition (\"NONE\", \"IF_ENEMY_BURNING\", \"IF_ENEMY_CHILLED\", \"IF_MY_HP_BELOW_HALF\", \"IF_ENEMY_HP_BELOW_HALF\" or \"IF_FIRST_CARD\").\n"
	p += "- cost: the total cost of the card, a whole number (use 0 if rejected).\n\n"
	p += "Turn the player's card text into these effects and decide its cost.\n"

	if version != 1:
		p += "\nRules of the game:\n"
		for rule_sentence in data["core_rules"]:
			p += "- %s\n" % rule_sentence
		if version == 3 or version == 4:
			p += "\nEffect rules (the ones most relevant to this card):\n"
			for r in picked:
				p += "- %s\n" % r["text"]
		else:
			p += "\nEffect rules:\n"
			for r in data["rules"]:
				p += "- %s\n" % r["text"]

	p += "\nThe player's card: \"%s\"\n" % card_text
	return p


func _content_words(text: String) -> Dictionary:
	var cleaned := punct_re.sub(text.to_lower(), "", true)
	cleaned = digit_letter_re.sub(cleaned, "$1 $2", true)
	cleaned = letter_digit_re.sub(cleaned, "$1 $2", true)
	var words := {}
	for w in cleaned.split(" ", false):
		if not STOPWORDS.has(w):
			words[w] = true
	return words


func _retrieve_rules(card_text: String) -> Array:
	var q_words := _content_words(card_text)
	var scored: Array = []
	var rules: Array = data["rules"]
	for i in rules.size():
		var r_words := _content_words(rules[i]["text"])
		var overlap := 0
		for w in q_words:
			if r_words.has(w):
				overlap += 1
		scored.append({"index": i, "overlap": overlap})
	scored.sort_custom(func(a, b): return a["overlap"] > b["overlap"] or (a["overlap"] == b["overlap"] and a["index"] < b["index"]))
	var top: Array = []
	for s in scored.slice(0, RAG_RULE_COUNT):
		top.append(rules[s["index"]])
	return top


func _effect_keys(effects: Array) -> Array:
	var keys: Array = []
	for e in effects:
		keys.append("%s|%s|%s|%s" % [e["keyword"], "null" if e["n"] == null else str(e["n"]), e["target"], e["condition"]])
	keys.sort()
	return keys


func _describe_effects(effects) -> String:
	if effects == null or effects.is_empty():
		return "[]"
	var parts: Array = []
	for e in effects:
		parts.append("%s %s %s %s" % [e["keyword"], "null" if e["n"] == null else str(e["n"]), e["target"], e["condition"]])
	return "[" + "; ".join(PackedStringArray(parts)) + "]"


func _describe_expected(entry: Dictionary) -> String:
	if entry["expected_reject"]:
		return "reject"
	var options: Array = []
	for opt in entry["accepted"]:
		options.append(_describe_effects(opt))
	return "%s cost %s" % [" OR ".join(PackedStringArray(options)), str(entry["expected_cost"])]


func _ask(version: int, card: Dictionary) -> Dictionary:
	var picked: Array = []
	var picked_keywords: Array = []
	var rag_hit = null
	if version == 3 or version == 4:
		picked = _retrieve_rules(card["text"])
		for r in picked:
			picked_keywords.append(r["keyword"])
		if not card["needed_rules"].is_empty():
			rag_hit = true
			for k in card["needed_rules"]:
				if not picked_keywords.has(k):
					rag_hit = false

	var accepted: Array = []
	for opt in card["accepted"]:
		accepted.append(_normalize_effects(opt))

	var prompt := _build_prompt(version, card["text"], picked)
	var entry := {
		"id": card["id"],
		"category": card["category"],
		"text": card["text"],
		"expected_reject": card["reject"],
		"accepted": accepted,
		"expected_cost": null if card["cost"] == null else int(card["cost"]),
		"needed_rules": card["needed_rules"],
		"retrieved_rule_keywords": picked_keywords,
		"rag_hit": rag_hit,
		"prompt_chars": prompt.length(),
		"ai_output": null,
		"ai_cost": null,
		"final_reject": null,
		"final_effects": null,
		"final_cost": null,
		"reason": null,
		"correct": false,
		"effects_correct": null,
		"cost_correct": null,
		"wrong_reject": false,
		"wrong_pass": false,
		"regenerations": 0,
		"fallback_used": false,
		"code_action": null,
		"attempts": [],
		"time_ms": 0,
		"error": null
	}

	var api_ms := 0
	if version >= 4:
		api_ms += await _answer_with_code_check(prompt, entry)
	else:
		var res: Dictionary = await _call_gemini(prompt, _schema())
		api_ms += res["api_ms"]
		if not res["ok"]:
			entry["error"] = res["error"]
		else:
			var reply := _parse_reply(res["text"])
			if reply.is_empty():
				entry["error"] = "Invalid JSON reply: " + str(res["text"]).left(200)
			else:
				entry["ai_output"] = reply
				entry["ai_cost"] = reply["cost"]
				entry["reason"] = reply["reason"]
				entry["final_reject"] = reply["reject"]
				if reply["reject"]:
					entry["final_effects"] = []
				else:
					entry["final_effects"] = reply["effects"]
					entry["final_cost"] = reply["cost"]

	entry["time_ms"] = api_ms
	if entry["error"] == null and entry["final_reject"] != null:
		_score(entry)
	return entry


func _answer_with_code_check(prompt: String, entry: Dictionary) -> int:
	var api_ms := 0
	var hint := ""
	var schema := _schema()
	var last_violations: Array = []
	for attempt in range(MAX_REGENERATIONS + 1):
		entry["regenerations"] = attempt
		var full_prompt := prompt + hint
		var res: Dictionary = await _call_gemini(full_prompt, schema)
		api_ms += res["api_ms"]
		if not res["ok"]:
			entry["error"] = res["error"]
			return api_ms

		var record := {"attempt": attempt, "prompt_chars": full_prompt.length(), "parse_ok": false, "output": null, "violations": []}
		entry["attempts"].append(record)
		var reply := _parse_reply(res["text"])
		var violations: Array = []
		if reply.is_empty():
			violations = [{"message": "The reply was not valid JSON for the required format.", "rule_text": ""}]
		else:
			record["parse_ok"] = true
			record["output"] = reply
			entry["ai_output"] = reply
			entry["ai_cost"] = reply["cost"]
			if reply["reject"]:
				entry["code_action"] = "ai_reject"
				entry["reason"] = reply["reason"]
				entry["final_reject"] = true
				entry["final_effects"] = []
				return api_ms
			violations = _check_card(reply["effects"])

		for v in violations:
			record["violations"].append(v["message"])
		if violations.is_empty():
			entry["code_action"] = "ok"
			entry["reason"] = reply["reason"]
			entry["final_reject"] = false
			entry["final_effects"] = reply["effects"]
			entry["final_cost"] = _calc_cost(reply["effects"])
			return api_ms
		last_violations = violations
		hint = _build_hint(violations)

	var messages: Array = []
	for v in last_violations:
		messages.append(v["message"])
	entry["code_action"] = "code_reject"
	entry["fallback_used"] = true
	entry["reason"] = "Rejected by the code after %d attempts. Still breaking: %s" % [MAX_REGENERATIONS + 1, " ".join(PackedStringArray(messages))]
	entry["final_reject"] = true
	entry["final_effects"] = []
	return api_ms


func _score(entry: Dictionary):
	var rejected: bool = entry["final_reject"]
	if entry["expected_reject"]:
		entry["correct"] = rejected
		entry["wrong_pass"] = not rejected
		return
	if rejected:
		entry["wrong_reject"] = true
		entry["effects_correct"] = false
		entry["cost_correct"] = false
		entry["correct"] = false
		return
	var final_keys := _effect_keys(entry["final_effects"])
	var effects_ok := false
	for opt in entry["accepted"]:
		if _effect_keys(opt) == final_keys:
			effects_ok = true
	entry["effects_correct"] = effects_ok
	entry["cost_correct"] = entry["final_cost"] == entry["expected_cost"]
	entry["correct"] = effects_ok and entry["cost_correct"]


func _percent(correct: int, total: int) -> float:
	return 100.0 * correct / maxi(total, 1)


func _mean(values: Array) -> float:
	if values.is_empty():
		return 0.0
	var total := 0.0
	for v in values:
		total += v
	return total / values.size()


func _median(values: Array) -> float:
	if values.is_empty():
		return 0.0
	var sorted_values := values.duplicate()
	sorted_values.sort()
	var mid := sorted_values.size() / 2
	if sorted_values.size() % 2 == 1:
		return float(sorted_values[mid])
	return (sorted_values[mid - 1] + sorted_values[mid]) / 2.0


func _summarize(runs: int, entries: Array) -> Dictionary:
	var per_run: Array = []
	for r in range(1, runs + 1):
		var correct := 0
		var valid := 0
		for e in entries:
			if e["run"] == r and e["error"] == null:
				valid += 1
				if e["correct"]:
					correct += 1
		per_run.append(_percent(correct, valid))
	var avg_accuracy := 0.0
	for a in per_run:
		avg_accuracy += a
	avg_accuracy /= per_run.size()

	var cat_total := {}
	var cat_correct := {}
	for c in CATEGORIES:
		cat_total[c] = 0
		cat_correct[c] = 0
	var piece_total := 0
	var effects_correct := 0
	var cost_correct := 0
	var wrong_rejects := 0
	var wrong_passes := 0
	var rag_total := 0
	var rag_hits := 0
	var regenerations := 0
	var code_rejections := 0
	var errors := 0
	var valid_times: Array = []
	for e in entries:
		regenerations += e["regenerations"]
		if e["error"] != null:
			errors += 1
			continue
		valid_times.append(e["time_ms"])
		cat_total[e["category"]] += 1
		if e["correct"]:
			cat_correct[e["category"]] += 1
		if e["fallback_used"]:
			code_rejections += 1
		if e["wrong_reject"]:
			wrong_rejects += 1
		if e["wrong_pass"]:
			wrong_passes += 1
		if not e["expected_reject"]:
			piece_total += 1
			if e["effects_correct"]:
				effects_correct += 1
			if e["cost_correct"]:
				cost_correct += 1
		if e["rag_hit"] != null:
			rag_total += 1
			if e["rag_hit"]:
				rag_hits += 1

	var category_accuracy := {}
	for c in CATEGORIES:
		category_accuracy[c] = null if cat_total[c] == 0 else _percent(cat_correct[c], cat_total[c])
	return {
		"per_run_accuracy": per_run,
		"avg_accuracy": avg_accuracy,
		"category_accuracy": category_accuracy,
		"effects_accuracy": _percent(effects_correct, piece_total),
		"cost_accuracy": _percent(cost_correct, piece_total),
		"wrong_rejects": wrong_rejects,
		"wrong_passes": wrong_passes,
		"rag_hit_rate": null if rag_total == 0 else _percent(rag_hits, rag_total),
		"regenerations": regenerations,
		"code_rejections": code_rejections,
		"avg_time_ms": _mean(valid_times),
		"median_time_ms": _median(valid_times),
		"errors": errors
	}


func _row_cells(version: int, runs: int, s: Dictionary) -> Array:
	var per_run_parts: Array = []
	for a in s["per_run_accuracy"]:
		per_run_parts.append("%.1f" % a)
	var cells: Array = [
		"v%d (%s)" % [version, VERSION_NAMES[version]],
		str(runs),
		" / ".join(PackedStringArray(per_run_parts)),
		"%.1f" % s["avg_accuracy"]
	]
	for c in CATEGORIES:
		var acc = s["category_accuracy"][c]
		cells.append("n/a" if acc == null else "%.1f" % acc)
	cells.append("%.1f" % s["effects_accuracy"])
	cells.append("%.1f" % s["cost_accuracy"])
	cells.append(str(s["wrong_rejects"]))
	cells.append(str(s["wrong_passes"]))
	cells.append("n/a" if s["rag_hit_rate"] == null else "%.1f" % s["rag_hit_rate"])
	cells.append(str(s["regenerations"]))
	cells.append(str(s["code_rejections"]))
	cells.append("%.0f" % s["avg_time_ms"])
	cells.append("%.0f" % s["median_time_ms"])
	cells.append(str(s["errors"]))
	return cells


func _print_table(version: int, runs: int, s: Dictionary):
	print("")
	print("| " + " | ".join(PackedStringArray(TABLE_COLUMNS)) + " |")
	var separator: Array = []
	for c in TABLE_COLUMNS:
		separator.append("---")
	print("| " + " | ".join(PackedStringArray(separator)) + " |")
	print("| " + " | ".join(PackedStringArray(_row_cells(version, runs, s))) + " |")
	print("")


func _print_progress(version: int, run: int, entry: Dictionary):
	var mark := "OK" if entry["correct"] else "WRONG"
	var outcome := "reject" if entry["final_reject"] == true else "effects=%s cost=%s" % [_describe_effects(entry["final_effects"]), str(entry["final_cost"])]
	var extras := " prompt=%d chars" % entry["prompt_chars"]
	if entry["regenerations"] > 0:
		extras += " regen=%d" % entry["regenerations"]
	if entry["fallback_used"]:
		extras += " CODE_REJECT"
	if entry["error"] != null:
		extras += " ERROR=" + str(entry["error"]).left(120)
	print("[v%d r%d] %s (%s) -> %s | %s %dms%s" % [version, run, entry["id"], entry["category"], outcome, mark, entry["time_ms"], extras])


func _timestamp(for_filename: bool) -> String:
	var t := Time.get_datetime_dict_from_system()
	if for_filename:
		return "%04d%02d%02d_%02d%02d%02d" % [t["year"], t["month"], t["day"], t["hour"], t["minute"], t["second"]]
	return "%04d-%02d-%02d %02d:%02d:%02d" % [t["year"], t["month"], t["day"], t["hour"], t["minute"], t["second"]]


func _write_results(version: int, runs: int, stamp: String, entries: Array, summary: Dictionary, dryrun: bool):
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(RESULTS_DIR))
	var prefix := "dryrun_" if dryrun else ""
	var path := "%s/%srulebook_v%d_%s.json" % [RESULTS_DIR, prefix, version, stamp]
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write " + path)
		return
	file.store_string(JSON.stringify({
		"version": version,
		"version_name": VERSION_NAMES[version],
		"runs": runs,
		"model": MODEL,
		"timestamp": _timestamp(false),
		"summary": summary,
		"results": entries
	}, "\t"))
	file.close()
	print("Saved " + path)


func _review_block(entry: Dictionary, tag: String) -> String:
	var ai = entry["ai_output"]
	var b := "### %s %s (run %d, %s)\n\n" % [tag, entry["id"], entry["run"], entry["category"]]
	b += "- Card: \"%s\"\n" % entry["text"]
	if entry["error"] != null:
		b += "- Error: %s\n\n" % str(entry["error"]).left(200)
		return b
	if ai == null:
		b += "- AI output: none\n"
	else:
		b += "- AI output: reject=%s, effects=%s, cost=%s\n" % [str(ai["reject"]), _describe_effects(ai["effects"]), str(ai["cost"])]
	b += "- Final answer: %s, cost %s\n" % ["reject" if entry["final_reject"] else _describe_effects(entry["final_effects"]), str(entry["final_cost"])]
	b += "- Expected: %s\n" % _describe_expected(entry)
	b += "- Reason given: %s\n" % str(entry["reason"])
	if not entry["attempts"].is_empty():
		for a in entry["attempts"]:
			var output_text := "no output"
			var check_text := "passed" if a["violations"].is_empty() else " / ".join(PackedStringArray(a["violations"]))
			if a["output"] != null:
				output_text = "reject=%s effects=%s" % [str(a["output"]["reject"]), _describe_effects(a["output"]["effects"])]
				if a["output"]["reject"]:
					check_text = "not run (AI rejected)"
			b += "- Attempt %d: %s | code check: %s\n" % [a["attempt"], output_text, check_text]
	b += "\n"
	return b


func _write_review(version: int, entries: Array, dryrun: bool):
	var wrong: Array = []
	var rejections: Array = []
	for e in entries:
		if e["error"] != null:
			continue
		if not e["correct"]:
			wrong.append(e)
		if e["final_reject"] == true:
			rejections.append(e)
	var out := "# Rulebook eval review: v%d (%s)\n\n" % [version, VERSION_NAMES[version]]
	out += "Written %s. Read the reasons and check whether the AI made up a rule that is not in the rulebook.\n\n" % _timestamp(false)
	out += "## Wrong cards (%d)\n\n" % wrong.size()
	for e in wrong:
		out += _review_block(e, "Wrong")
	out += "## All rejections (%d)\n\n" % rejections.size()
	for e in rejections:
		out += _review_block(e, "Rejected")
	var prefix := "dryrun_" if dryrun else ""
	var path := "%s/%srulebook_v%d_review.md" % [RESULTS_DIR, prefix, version]
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write " + path)
		return
	file.store_string(out)
	file.close()
	print("Saved " + path)


func _append_summary_md(version: int, runs: int, summary: Dictionary):
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(RESULTS_DIR))
	var path := summary_path
	var exists := FileAccess.file_exists(path)
	var file := FileAccess.open(path, FileAccess.READ_WRITE if exists else FileAccess.WRITE)
	if file == null:
		push_error("Cannot write " + path)
		return
	if exists:
		file.seek_end()
	else:
		var columns: Array = ["Time"]
		columns.append_array(TABLE_COLUMNS)
		var separator: Array = []
		for c in columns:
			separator.append("---")
		file.store_line("# Rulebook Eval Summary")
		file.store_line("")
		file.store_line("Time per card is API call time including regenerations; the 5s pacing waits and 429 backoffs are excluded.")
		file.store_line("")
		file.store_line("Time per card (average and median) excludes cards that ended in an API error.")
		file.store_line("")
		file.store_line("Accuracy excludes cards that ended in an API error; those are counted in the Errors column.")
		file.store_line("")
		file.store_line("Effects and cost accuracy are computed over the cards that should not be rejected. RAG hit rate counts cards whose needed rules were all among the picked rules (v3 and v4 only).")
		file.store_line("")
		file.store_line("| " + " | ".join(PackedStringArray(columns)) + " |")
		file.store_line("| " + " | ".join(PackedStringArray(separator)) + " |")
	var cells: Array = [_timestamp(false)]
	cells.append_array(_row_cells(version, runs, summary))
	file.store_line("| " + " | ".join(PackedStringArray(cells)) + " |")
	file.close()
	print("Updated " + path)
