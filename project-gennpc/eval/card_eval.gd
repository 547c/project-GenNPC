extends Node

const MODEL := "gemini-3.5-flash-lite"
const URL := "https://generativelanguage.googleapis.com/v1beta/models/" + MODEL + ":generateContent"
const DATA_PATH := "res://eval/card_data.json"
const RESULTS_DIR := "res://eval/results"
const CALL_GAP_SEC := 5.0
const RATE_LIMIT_WAIT_SEC := 30.0
const MAX_RATE_LIMIT_RETRIES := 3
const MAX_REGENERATIONS := 2
const REQUEST_TIMEOUT_SEC := 90.0
const MIN_N := 1
const MAX_N := 30

const EFFECT_TYPES := ["DAMAGE", "HEAL", "SHIELD", "DRAW", "BURN", "WEAKEN"]
const TARGETS := ["single", "all"]
const CONDITIONS := ["none", "IF_ENEMY_BURNING", "IF_MY_HP_BELOW_HALF"]
const DOUBLE_COST_TYPES := ["DRAW", "BURN", "WEAKEN"]
const SINGLE_ONLY_TYPES := ["HEAL", "SHIELD", "DRAW"]
const STOPWORDS := ["a", "an", "the", "was", "were", "is", "are", "did", "do", "does", "you", "i", "it", "at", "in", "on", "of", "to", "that", "who", "what", "me", "my", "your", "around", "just", "tell"]
const VERSION_NAMES := {1: "AI only", 2: "AI + examples", 3: "AI + examples + code check"}
const TABLE_COLUMNS := ["Version", "Runs", "Accuracy per run (%)", "Avg accuracy (%)", "Normal accuracy (%)", "Hard accuracy (%)", "Trick accuracy (%)", "Effects accuracy (%)", "Cost accuracy (%)", "Avg time/card (ms)", "Regenerations", "Fallbacks", "Errors"]

var api_key := ""
var data: Dictionary = {}
var http: HTTPRequest
var punct_re := RegEx.new()
var digit_letter_re := RegEx.new()
var letter_digit_re := RegEx.new()
var first_call := true
var aborted := false
var abort_message := ""


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
	if version < 1 or version > 3 or runs < 1:
		print("Usage: -- --version=1..3 [--runs=R]")
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

	print("=== Card eval: version %d (%s), runs %d, model %s ===" % [version, VERSION_NAMES[version], runs, MODEL])

	var entries: Array = []
	for run in range(1, runs + 1):
		for card in data["tests"]:
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
	_print_table(version, runs, summary)
	_write_results(version, runs, _timestamp(true), entries, summary)
	_append_summary_md(version, runs, summary)
	return 0


func _parse_args() -> Dictionary:
	var out := {"version": 0, "runs": 3}
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--version="):
			out["version"] = int(arg.substr("--version=".length()))
		elif arg.begins_with("--runs="):
			out["runs"] = int(arg.substr("--runs=".length()))
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
	return true


func _schema(with_cost: bool) -> Dictionary:
	var props := {
		"reject": {"type": "BOOLEAN"},
		"reason": {"type": "STRING"},
		"effects": {
			"type": "ARRAY",
			"items": {
				"type": "OBJECT",
				"properties": {
					"type": {"type": "STRING", "enum": EFFECT_TYPES},
					"n": {"type": "INTEGER"},
					"target": {"type": "STRING", "enum": TARGETS},
					"condition": {"type": "STRING", "enum": CONDITIONS}
				},
				"required": ["type", "n", "target", "condition"]
			}
		}
	}
	var required := ["reject", "reason", "effects"]
	if with_cost:
		props["cost"] = {"type": "INTEGER"}
		required = ["reject", "reason", "effects", "cost"]
	return {"type": "OBJECT", "properties": props, "required": required}


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
	if not _is_whole_number(e.get("n")):
		return {}
	if not EFFECT_TYPES.has(e.get("type")) or not TARGETS.has(e.get("target")) or not CONDITIONS.has(e.get("condition")):
		return {}
	return {"type": e["type"], "n": int(e["n"]), "target": e["target"], "condition": e["condition"]}


func _normalize_effects(raw: Array) -> Array:
	var out: Array = []
	for e in raw:
		out.append(_normalize_effect(e))
	return out


func _parse_reply(text: String, with_cost: bool) -> Dictionary:
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	if typeof(parsed.get("reject")) != TYPE_BOOL or typeof(parsed.get("reason")) != TYPE_STRING:
		return {}
	var raw_effects = parsed.get("effects")
	if typeof(raw_effects) != TYPE_ARRAY:
		return {}
	var effects: Array = []
	for e in raw_effects:
		var norm := _normalize_effect(e)
		if norm.is_empty():
			return {}
		effects.append(norm)
	var out := {"reject": parsed["reject"], "reason": parsed["reason"], "effects": effects, "cost": null}
	if with_cost:
		var cost = parsed.get("cost")
		if not _is_whole_number(cost):
			return {}
		out["cost"] = int(cost)
	return out


func _calc_cost(effects: Array) -> int:
	var total := 0
	for e in effects:
		var c: int = e["n"]
		if DOUBLE_COST_TYPES.has(e["type"]):
			c *= 2
		if e["target"] == "all":
			c *= 2
		if e["condition"] != "none":
			c = ceili(c / 2.0)
		total += c
	return total


func _effect_keys(effects: Array) -> Array:
	var keys: Array = []
	for e in effects:
		keys.append("%s|%d|%s|%s" % [e["type"], e["n"], e["target"], e["condition"]])
	keys.sort()
	return keys


func _describe_effects(effects) -> String:
	if effects == null or effects.is_empty():
		return "[]"
	var parts: Array = []
	for e in effects:
		parts.append("%s %d %s %s" % [e["type"], e["n"], e["target"], e["condition"]])
	return "[" + "; ".join(PackedStringArray(parts)) + "]"


func _build_prompt(version: int, card_text: String, examples: Array) -> String:
	var with_cost := version != 3
	var p := "You turn a card description written by a player into structured card effects for a card game.\n\n"
	p += "Effect pieces. Each effect has type, n, target and condition.\n"
	p += "- type: DAMAGE (deal damage), HEAL (restore the player's health), SHIELD (gain block), DRAW (draw cards), BURN (set enemies on fire for n turns), WEAKEN (weaken enemies for n turns).\n"
	p += "- n: a whole number.\n"
	p += "- target: \"single\" or \"all\". \"all\" means all enemies. HEAL, SHIELD and DRAW always use \"single\".\n"
	p += "- condition: \"none\", \"IF_ENEMY_BURNING\" (only if the enemy is burning), or \"IF_MY_HP_BELOW_HALF\" (only if the player's health is below half).\n\n"
	if with_cost:
		p += "Cost rules (n may only be 1 to 30):\n"
		p += "1. Base cost: DAMAGE, HEAL and SHIELD cost n. DRAW, BURN and WEAKEN cost 2n.\n"
		p += "2. If target is \"all\", multiply the cost by 2.\n"
		p += "3. If there is a condition, halve the cost, rounding up.\n"
		p += "4. If the card has several effects, add up their costs.\n\n"
		p += "Reject the card (reject = true, effects = [], cost = 0) if n would be outside 1 to 30, or if the card cannot be made from these effect pieces. Give a short reason.\n"
		p += "Reply with a JSON object with reject, reason, effects and cost (the total cost).\n"
	else:
		p += "Reject the card (reject = true, effects = []) if it cannot be made from these effect pieces. Give a short reason.\n"
		p += "Reply with a JSON object with reject, reason and effects. Do not work out the cost.\n"

	if version >= 2:
		p += "\nExamples of similar cards with their correct answers:\n"
		for ex in examples:
			var answer := {"reject": ex["reject"], "reason": "", "effects": _normalize_effects(ex["effects"])}
			if ex["reject"]:
				answer["reason"] = "This cannot be made from the available effect pieces."
			if with_cost:
				answer["cost"] = 0 if ex["reject"] else int(ex["cost"])
			p += "Card: \"%s\"\nAnswer: %s\n" % [ex["text"], JSON.stringify(answer)]

	p += "\nNow convert this card:\nCard: \"%s\"\n" % card_text
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


func _retrieve(card_text: String) -> Array:
	var q_words := _content_words(card_text)
	var scored: Array = []
	var examples: Array = data["examples"]
	for i in examples.size():
		var e_words := _content_words(examples[i]["text"])
		var overlap := 0
		for w in q_words:
			if e_words.has(w):
				overlap += 1
		scored.append({"index": i, "overlap": overlap})
	scored.sort_custom(func(a, b): return a["overlap"] > b["overlap"] or (a["overlap"] == b["overlap"] and a["index"] < b["index"]))
	var top: Array = []
	for s in scored.slice(0, 3):
		top.append(examples[s["index"]])
	return top


func _check_output(reply: Dictionary) -> Dictionary:
	var effects: Array = reply["effects"]
	if not reply["reject"]:
		for e in effects:
			if e["n"] < MIN_N or e["n"] > MAX_N:
				return {"action": "n_out_of_range", "reason": "n=%d is outside %d to %d." % [e["n"], MIN_N, MAX_N]}
	if reply["reject"] and not effects.is_empty():
		return {"action": "format_error", "reason": "reject is true but effects is not empty."}
	if not reply["reject"] and effects.is_empty():
		return {"action": "format_error", "reason": "effects is empty but reject is false."}
	for e in effects:
		if SINGLE_ONLY_TYPES.has(e["type"]) and e["target"] != "single":
			return {"action": "format_error", "reason": "%s must use target single." % e["type"]}
	return {"action": "ok", "reason": ""}


func _ask(version: int, card: Dictionary) -> Dictionary:
	var examples: Array = []
	if version >= 2:
		examples = _retrieve(card["text"])
	var example_ids: Array = []
	for ex in examples:
		example_ids.append(ex["id"])

	var entry := {
		"id": card["id"],
		"type": card["type"],
		"text": card["text"],
		"expected_reject": card["reject"],
		"expected_effects": _normalize_effects(card["effects"]),
		"expected_cost": null if card["cost"] == null else int(card["cost"]),
		"retrieved_example_ids": example_ids,
		"ai_output": null,
		"final_reject": null,
		"final_effects": null,
		"final_cost": null,
		"reason": null,
		"correct": false,
		"effects_correct": null,
		"cost_correct": null,
		"reject_correct": null,
		"regenerations": 0,
		"fallback_used": false,
		"time_ms": 0,
		"error": null
	}
	if version == 3:
		entry["first_output"] = null
		entry["attempts"] = []
		entry["code_action"] = null

	var prompt := _build_prompt(version, card["text"], examples)
	var schema := _schema(version != 3)
	var api_ms := 0

	if version == 3:
		api_ms += await _answer_with_code_check(prompt, schema, entry)
	else:
		var res: Dictionary = await _call_gemini(prompt, schema)
		api_ms += res["api_ms"]
		if not res["ok"]:
			entry["error"] = res["error"]
		else:
			var reply := _parse_reply(res["text"], true)
			if reply.is_empty():
				entry["error"] = "Invalid JSON reply: " + str(res["text"]).left(200)
			else:
				entry["ai_output"] = reply
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


func _answer_with_code_check(prompt: String, schema: Dictionary, entry: Dictionary) -> int:
	var api_ms := 0
	var hint := ""
	for attempt in range(MAX_REGENERATIONS + 1):
		entry["regenerations"] = attempt
		var res: Dictionary = await _call_gemini(prompt + hint, schema)
		api_ms += res["api_ms"]
		if not res["ok"]:
			entry["error"] = res["error"]
			return api_ms

		var record := {"attempt": attempt, "parse_ok": false, "output": null, "check": null, "reason": ""}
		entry["attempts"].append(record)
		var reply := _parse_reply(res["text"], false)
		var check: Dictionary
		if reply.is_empty():
			check = {"action": "format_error", "reason": "The reply did not match the required JSON format."}
		else:
			record["parse_ok"] = true
			record["output"] = {"reject": reply["reject"], "reason": reply["reason"], "effects": reply["effects"]}
			if attempt == 0:
				entry["first_output"] = record["output"]
			check = _check_output(reply)
		record["check"] = check["action"]
		record["reason"] = check["reason"]

		if check["action"] == "ok":
			entry["code_action"] = "ok"
			entry["reason"] = reply["reason"]
			if reply["reject"]:
				entry["final_reject"] = true
				entry["final_effects"] = []
			else:
				entry["final_reject"] = false
				entry["final_effects"] = reply["effects"]
				entry["final_cost"] = _calc_cost(reply["effects"])
			return api_ms
		if check["action"] == "n_out_of_range":
			entry["code_action"] = "n_out_of_range"
			entry["reason"] = check["reason"]
			entry["final_reject"] = true
			entry["final_effects"] = []
			return api_ms
		hint = "\n\nYour previous reply was invalid: %s Reply again with a valid JSON object." % check["reason"]

	entry["code_action"] = "fallback_reject"
	entry["fallback_used"] = true
	entry["reason"] = "Still invalid after %d attempts." % (MAX_REGENERATIONS + 1)
	entry["final_reject"] = true
	entry["final_effects"] = []
	return api_ms


func _score(entry: Dictionary):
	var expect_reject: bool = entry["expected_reject"]
	var rejected: bool = entry["final_reject"]
	entry["reject_correct"] = rejected == expect_reject
	if expect_reject:
		entry["correct"] = rejected
		return
	if rejected:
		entry["effects_correct"] = false
		entry["cost_correct"] = false
		entry["correct"] = false
		return
	entry["effects_correct"] = _effect_keys(entry["final_effects"]) == _effect_keys(entry["expected_effects"])
	entry["cost_correct"] = entry["final_cost"] == entry["expected_cost"]
	entry["correct"] = entry["effects_correct"] and entry["cost_correct"]


func _percent(correct: int, total: int) -> float:
	return 100.0 * correct / maxi(total, 1)


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

	var type_total := {"normal": 0, "hard": 0, "trick": 0}
	var type_correct := {"normal": 0, "hard": 0, "trick": 0}
	var piece_total := 0
	var effects_correct := 0
	var cost_correct := 0
	var regenerations := 0
	var fallbacks := 0
	var errors := 0
	var total_ms := 0
	for e in entries:
		regenerations += e["regenerations"]
		total_ms += e["time_ms"]
		if e["fallback_used"]:
			fallbacks += 1
		if e["error"] != null:
			errors += 1
			continue
		type_total[e["type"]] += 1
		if e["correct"]:
			type_correct[e["type"]] += 1
		if not e["expected_reject"]:
			piece_total += 1
			if e["effects_correct"]:
				effects_correct += 1
			if e["cost_correct"]:
				cost_correct += 1

	return {
		"per_run_accuracy": per_run,
		"avg_accuracy": avg_accuracy,
		"normal_accuracy": _percent(type_correct["normal"], type_total["normal"]),
		"hard_accuracy": _percent(type_correct["hard"], type_total["hard"]),
		"trick_accuracy": _percent(type_correct["trick"], type_total["trick"]),
		"effects_accuracy": _percent(effects_correct, piece_total),
		"cost_accuracy": _percent(cost_correct, piece_total),
		"avg_time_ms": float(total_ms) / entries.size(),
		"regenerations": regenerations,
		"fallbacks": fallbacks,
		"errors": errors
	}


func _row_cells(version: int, runs: int, s: Dictionary) -> Array:
	var per_run_parts: Array = []
	for a in s["per_run_accuracy"]:
		per_run_parts.append("%.1f" % a)
	return [
		"v%d (%s)" % [version, VERSION_NAMES[version]],
		str(runs),
		" / ".join(PackedStringArray(per_run_parts)),
		"%.1f" % s["avg_accuracy"],
		"%.1f" % s["normal_accuracy"],
		"%.1f" % s["hard_accuracy"],
		"%.1f" % s["trick_accuracy"],
		"%.1f" % s["effects_accuracy"],
		"%.1f" % s["cost_accuracy"],
		"%.0f" % s["avg_time_ms"],
		str(s["regenerations"]),
		str(s["fallbacks"]),
		str(s["errors"])
	]


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
	var extras := ""
	if entry["regenerations"] > 0:
		extras += " regen=%d" % entry["regenerations"]
	if entry["fallback_used"]:
		extras += " FALLBACK"
	if entry["error"] != null:
		extras += " ERROR=" + str(entry["error"]).left(120)
	print("[v%d r%d] %s (%s) -> %s | %s %dms%s" % [version, run, entry["id"], entry["type"], outcome, mark, entry["time_ms"], extras])


func _timestamp(for_filename: bool) -> String:
	var t := Time.get_datetime_dict_from_system()
	if for_filename:
		return "%04d%02d%02d_%02d%02d%02d" % [t["year"], t["month"], t["day"], t["hour"], t["minute"], t["second"]]
	return "%04d-%02d-%02d %02d:%02d:%02d" % [t["year"], t["month"], t["day"], t["hour"], t["minute"], t["second"]]


func _write_results(version: int, runs: int, stamp: String, entries: Array, summary: Dictionary):
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(RESULTS_DIR))
	var path := "%s/card_v%d_%s.json" % [RESULTS_DIR, version, stamp]
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


func _append_summary_md(version: int, runs: int, summary: Dictionary):
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(RESULTS_DIR))
	var path := RESULTS_DIR + "/card_summary.md"
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
		file.store_line("# Card Eval Summary")
		file.store_line("")
		file.store_line("Time per card is API call time including regenerations; the 5s pacing waits and 429 backoffs are excluded.")
		file.store_line("")
		file.store_line("Accuracy excludes cards that ended in an API error; those are counted in the Errors column.")
		file.store_line("")
		file.store_line("Effects and cost accuracy are computed over the cards that should not be rejected.")
		file.store_line("")
		file.store_line("| " + " | ".join(PackedStringArray(columns)) + " |")
		file.store_line("| " + " | ".join(PackedStringArray(separator)) + " |")
	var cells: Array = [_timestamp(false)]
	cells.append_array(_row_cells(version, runs, summary))
	file.store_line("| " + " | ".join(PackedStringArray(cells)) + " |")
	file.close()
	print("Updated " + path)
