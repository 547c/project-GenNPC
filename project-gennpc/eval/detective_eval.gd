extends Node

const MODEL := "gemini-3.5-flash-lite"
const URL := "https://generativelanguage.googleapis.com/v1beta/models/" + MODEL + ":generateContent"
const DATA_PATH := "res://eval/detective_data.json"
const RESULTS_DIR := "res://eval/results"
const CALL_GAP_SEC := 5.0
const RATE_LIMIT_WAIT_SEC := 30.0
const MAX_RATE_LIMIT_RETRIES := 3
const MAX_REGENERATIONS := 2
const REQUEST_TIMEOUT_SEC := 90.0

const ANSWERS := ["yes", "no", "unknown", "refuse"]
const STOPWORDS := ["a", "an", "the", "was", "were", "is", "are", "did", "do", "does", "you", "i", "it", "at", "in", "on", "of", "to", "that", "who", "what", "me", "my", "your", "around", "just", "tell"]
const SUBJECTS := ["necklace", "elena", "tom", "finn", "mara", "spare_keys", "inn", "festival", "kitchen", "case"]
const ATTRIBUTES := ["location_830pm", "location_9pm", "location_evening", "location", "knows_culprit", "took_necklace", "debts", "culprit", "years_worked", "dinner_time", "arrival", "room_count", "fireworks_time", "favorite_room", "dish_tonight", "hometown", "back_door"]
const VALUES := ["room2", "room4", "kitchen", "second_floor_stairs", "stable", "inn", "yard", "tom", "elena", "finn", "yes", "no", "7pm", "9pm", "10pm", "today", "yesterday", "fish_stew"]
const FALLBACK_LINES := {
	"yes": "Yes.",
	"no": "No.",
	"unknown": "I don't know.",
	"refuse": "I'd rather not talk about that."
}
const LEAK_PHRASES := ["i took", "i stole", "i did it", "it was me"]
const VERSION_NAMES := {1: "AI only", 2: "AI + all facts", 3: "AI + RAG", 4: "AI + RAG + code check"}
const TABLE_COLUMNS := ["Version", "Runs", "Accuracy per run (%)", "Avg accuracy (%)", "Knowledge accuracy (%)", "Role accuracy (%)", "Leaks", "Avg time/question (ms)", "Regenerations", "Fixed-line fallbacks", "Retrieval hit rate (%)", "Errors"]

var api_key := ""
var data: Dictionary = {}
var http: HTTPRequest
var punct_re := RegEx.new()
var value_re := RegEx.new()
var digit_letter_re := RegEx.new()
var letter_digit_re := RegEx.new()
var first_call := true
var aborted := false
var abort_message := ""


func _ready():
	punct_re.compile("[^a-z0-9\\s]")
	value_re.compile("[^a-z0-9]")
	digit_letter_re.compile("([0-9])([a-z])")
	letter_digit_re.compile("([a-z])([0-9])")
	var code: int = await _main()
	get_tree().quit(code)


func _main() -> int:
	var args := _parse_args()
	var version: int = args["version"]
	var runs: int = args["runs"]
	if version < 1 or version > 4 or runs < 1:
		print("Usage: -- --version=1..4 [--runs=R]")
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

	print("=== Detective eval: version %d (%s), runs %d, model %s ===" % [version, VERSION_NAMES[version], runs, MODEL])

	var entries: Array = []
	var question_count: int = data["questions"].size()
	for run in range(1, runs + 1):
		for q in data["questions"]:
			var entry: Dictionary = await _ask(version, q["npc"], q)
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

	var summary := _summarize(runs, question_count, entries)
	var stamp := _timestamp(true)
	_print_table(version, runs, summary)
	_write_results(version, runs, stamp, entries, summary)
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


func _schema(with_asked: bool) -> Dictionary:
	var props := {
		"answer": {"type": "STRING", "enum": ANSWERS},
		"line": {"type": "STRING"}
	}
	var required := ["answer", "line"]
	if with_asked:
		props["asked"] = {
			"type": "OBJECT",
			"properties": {
				"subject": {"type": "STRING"},
				"attribute": {"type": "STRING"},
				"value": {"type": "STRING"}
			},
			"required": ["subject", "attribute", "value"]
		}
		required = ["answer", "asked", "line"]
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


func _parse_reply(text: String, need_asked: bool) -> Dictionary:
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	var answer = parsed.get("answer")
	var line = parsed.get("line")
	if typeof(answer) != TYPE_STRING or not ANSWERS.has(answer) or typeof(line) != TYPE_STRING:
		return {}
	if need_asked:
		var asked = parsed.get("asked")
		if typeof(asked) != TYPE_DICTIONARY:
			return {}
		for key in ["subject", "attribute", "value"]:
			if typeof(asked.get(key)) != TYPE_STRING:
				return {}
	return parsed


func _build_prompt(version: int, npc_id: String, npc: Dictionary, question: String, retrieved: Array) -> String:
	var p := "You are %s, %s.\n" % [npc["name"], npc["role"]]
	p += "Personality: %s\n" % npc["personality"]
	p += "Case: %s\n\n" % data["case"]
	p += "A detective is questioning you about this case. Reply with a JSON object.\n\n"
	p += "Rules:\n"
	p += "- \"answer\": use \"yes\" or \"no\" when you can answer from what you know. Use \"unknown\" when you do not have that information. Use \"refuse\" when you know it but will not talk about it. If you are asked whether you know something and you do not, answer \"no\".\n"
	p += "- If the question is not a yes/no question (for example it asks who, what, or where), do not use \"yes\" or \"no\" as the answer. Use \"unknown\" or \"refuse\" instead.\n"
	p += "- Stay in character. \"line\" is what you say out loud: one or two short sentences.\n"
	if version >= 2:
		p += "- Do not make up anything that is not in the facts you were given.\n"
		var facts: Array = npc["facts"] if version == 2 else retrieved
		p += "\nFacts you know:\n"
		for f in facts:
			p += "- %s\n" % f["text"]
	if version == 4:
		p += "\nAlso fill \"asked\" with what the detective's question is asking about, as subject, attribute and value.\n"
		p += "- \"you\" means yourself (subject \"%s\").\n" % npc_id
		p += "- For a question like \"Did X do Y?\" or \"Is X Y?\", set value to \"yes\".\n"
		p += "- Choose subject and attribute from these lists.\n"
		p += "subjects: %s\n" % ", ".join(PackedStringArray(SUBJECTS))
		p += "attributes: %s\n" % ", ".join(PackedStringArray(ATTRIBUTES))
		p += "- Common values: %s\n" % ", ".join(PackedStringArray(VALUES))
		p += "- Write times as a number followed by pm, like 7pm.\n"
	p += "\nThe detective asks: \"%s\"\n" % question
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


func _retrieve(npc: Dictionary, question: String) -> Array:
	var q_words := _content_words(question)
	var scored: Array = []
	var facts: Array = npc["facts"]
	for i in facts.size():
		var f_words := _content_words(facts[i]["text"])
		var overlap := 0
		for w in q_words:
			if f_words.has(w):
				overlap += 1
		scored.append({"index": i, "overlap": overlap})
	scored.sort_custom(func(a, b): return a["overlap"] > b["overlap"] or (a["overlap"] == b["overlap"] and a["index"] < b["index"]))
	var top: Array = []
	for s in scored.slice(0, 3):
		top.append(facts[s["index"]])
	return top


func _normalize_value(v: String) -> String:
	return value_re.sub(v.to_lower(), "", true)


func _expected_from_asked(npc: Dictionary, asked: Dictionary) -> Dictionary:
	var subject: String = asked["subject"].strip_edges().to_lower()
	var attribute: String = asked["attribute"].strip_edges().to_lower()
	for f in npc["facts"]:
		if f["subject"].to_lower() == subject and f["attribute"].to_lower() == attribute:
			var fact_value := _normalize_value(f["value"])
			if fact_value == "refuse":
				return {"answer": "refuse", "fact_text": f["text"]}
			if fact_value == _normalize_value(asked["value"]):
				return {"answer": "yes", "fact_text": f["text"]}
			return {"answer": "no", "fact_text": f["text"]}
	return {"answer": "unknown", "fact_text": ""}


func _hint_for(expected: Dictionary) -> String:
	match expected["answer"]:
		"unknown":
			return "You do not have information about this."
		"refuse":
			return "You refuse to talk about this."
	return expected["fact_text"]


func _ask(version: int, npc_id: String, q: Dictionary) -> Dictionary:
	var npc: Dictionary = data["npcs"][npc_id]
	var retrieved: Array = []
	if version >= 3:
		retrieved = _retrieve(npc, q["question"])
	var retrieved_ids: Array = []
	for f in retrieved:
		retrieved_ids.append(f["id"])
	var hit = null
	if version >= 3 and q["needed_fact"] != null:
		hit = retrieved_ids.has(q["needed_fact"])

	var entry := {
		"id": int(q["id"]),
		"npc": npc_id,
		"question": q["question"],
		"type": q["type"],
		"accepted": q["accepted"],
		"ai_answer": null,
		"final_answer": null,
		"line": null,
		"correct": false,
		"retrieved_fact_ids": retrieved_ids,
		"retrieval_hit": hit,
		"asked": null,
		"regenerations": 0,
		"fallback_used": false,
		"leak": false,
		"time_ms": 0,
		"error": null
	}

	if version == 4:
		entry["first_answer"] = null
		entry["first_line"] = null
		entry["first_asked"] = null
		entry["first_correct"] = null
		entry["attempts"] = []

	var prompt := _build_prompt(version, npc_id, npc, q["question"], retrieved)
	var schema := _schema(version == 4)
	var api_ms := 0

	if version < 4:
		var res: Dictionary = await _call_gemini(prompt, schema)
		api_ms += res["api_ms"]
		if not res["ok"]:
			entry["error"] = res["error"]
		else:
			var reply := _parse_reply(res["text"], false)
			if reply.is_empty():
				entry["error"] = "Invalid JSON reply: " + str(res["text"]).left(200)
			else:
				entry["ai_answer"] = reply["answer"]
				entry["final_answer"] = reply["answer"]
				entry["line"] = reply["line"]
	else:
		api_ms += await _answer_with_code_check(npc, prompt, schema, entry)

	entry["time_ms"] = api_ms
	if entry.has("first_answer") and entry["first_answer"] != null:
		entry["first_correct"] = q["accepted"].has(entry["first_answer"])
	if entry["final_answer"] != null:
		entry["correct"] = q["accepted"].has(entry["final_answer"])
	if npc_id == "tom" and entry["line"] != null:
		var lowered: String = entry["line"].to_lower()
		for phrase in LEAK_PHRASES:
			if lowered.contains(phrase):
				entry["leak"] = true
	return entry


func _answer_with_code_check(npc: Dictionary, prompt: String, schema: Dictionary, entry: Dictionary) -> int:
	var api_ms := 0
	var hint := ""
	var last_expected: Dictionary = {}
	for attempt in range(MAX_REGENERATIONS + 1):
		entry["regenerations"] = attempt
		var res: Dictionary = await _call_gemini(prompt + hint, schema)
		api_ms += res["api_ms"]
		if not res["ok"]:
			entry["error"] = res["error"]
			return api_ms
		var record := {"attempt": attempt, "parse_ok": false, "answer": null, "line": null, "asked": null, "expected": null}
		entry["attempts"].append(record)
		var reply := _parse_reply(res["text"], true)
		if reply.is_empty():
			continue
		entry["ai_answer"] = reply["answer"]
		entry["asked"] = reply["asked"]
		var expected := _expected_from_asked(npc, reply["asked"])
		last_expected = expected
		record["parse_ok"] = true
		record["answer"] = reply["answer"]
		record["line"] = reply["line"]
		record["asked"] = reply["asked"]
		record["expected"] = expected["answer"]
		if attempt == 0:
			entry["first_answer"] = reply["answer"]
			entry["first_line"] = reply["line"]
			entry["first_asked"] = reply["asked"]
		if reply["answer"] == expected["answer"]:
			entry["final_answer"] = reply["answer"]
			entry["line"] = reply["line"]
			return api_ms
		hint = "\n\nReminder: " + _hint_for(expected)

	if last_expected.is_empty():
		entry["error"] = "No valid reply after %d attempts" % (MAX_REGENERATIONS + 1)
	else:
		entry["final_answer"] = last_expected["answer"]
		entry["line"] = FALLBACK_LINES[last_expected["answer"]]
		entry["fallback_used"] = true
	return api_ms


func _summarize(runs: int, question_count: int, entries: Array) -> Dictionary:
	var per_run: Array = []
	for r in range(1, runs + 1):
		var correct := 0
		var valid := 0
		for e in entries:
			if e["run"] == r and e["error"] == null:
				valid += 1
				if e["correct"]:
					correct += 1
		per_run.append(100.0 * correct / maxi(valid, 1))
	var avg_accuracy := 0.0
	for a in per_run:
		avg_accuracy += a
	avg_accuracy /= per_run.size()

	var leaks := 0
	var regenerations := 0
	var fallbacks := 0
	var errors := 0
	var total_ms := 0
	var needed := 0
	var hits := 0
	var type_total := {"knowledge": 0, "role": 0}
	var type_correct := {"knowledge": 0, "role": 0}
	for e in entries:
		if e["error"] == null:
			type_total[e["type"]] += 1
			if e["correct"]:
				type_correct[e["type"]] += 1
		if e["leak"]:
			leaks += 1
		regenerations += e["regenerations"]
		if e["fallback_used"]:
			fallbacks += 1
		if e["error"] != null:
			errors += 1
		total_ms += e["time_ms"]
		if e["retrieval_hit"] != null:
			needed += 1
			if e["retrieval_hit"]:
				hits += 1

	var hit_rate = null
	if needed > 0:
		hit_rate = 100.0 * hits / needed
	return {
		"per_run_accuracy": per_run,
		"avg_accuracy": avg_accuracy,
		"knowledge_accuracy": 100.0 * type_correct["knowledge"] / maxi(type_total["knowledge"], 1),
		"role_accuracy": 100.0 * type_correct["role"] / maxi(type_total["role"], 1),
		"leaks": leaks,
		"avg_time_ms": float(total_ms) / entries.size(),
		"regenerations": regenerations,
		"fixed_line_fallbacks": fallbacks,
		"retrieval_hit_rate": hit_rate,
		"errors": errors
	}


func _row_cells(version: int, runs: int, s: Dictionary) -> Array:
	var per_run_parts: Array = []
	for a in s["per_run_accuracy"]:
		per_run_parts.append("%.1f" % a)
	var hit_text := "n/a"
	if s["retrieval_hit_rate"] != null:
		hit_text = "%.1f" % s["retrieval_hit_rate"]
	return [
		"v%d (%s)" % [version, VERSION_NAMES[version]],
		str(runs),
		" / ".join(PackedStringArray(per_run_parts)),
		"%.1f" % s["avg_accuracy"],
		"%.1f" % s["knowledge_accuracy"],
		"%.1f" % s["role_accuracy"],
		str(s["leaks"]),
		"%.0f" % s["avg_time_ms"],
		str(s["regenerations"]),
		str(s["fixed_line_fallbacks"]),
		hit_text,
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
	var extras := ""
	if entry["regenerations"] > 0:
		extras += " regen=%d first=%s" % [entry["regenerations"], str(entry.get("first_answer"))]
	if entry["fallback_used"]:
		extras += " FALLBACK"
	if entry["leak"]:
		extras += " LEAK"
	if entry["error"] != null:
		extras += " ERROR=" + str(entry["error"]).left(120)
	print("[v%d r%d] Q%d (%s) -> %s accepted=%s %s %dms%s" % [version, run, entry["id"], entry["npc"], str(entry["final_answer"]), str(entry["accepted"]), mark, entry["time_ms"], extras])


func _timestamp(for_filename: bool) -> String:
	var t := Time.get_datetime_dict_from_system()
	if for_filename:
		return "%04d%02d%02d_%02d%02d%02d" % [t["year"], t["month"], t["day"], t["hour"], t["minute"], t["second"]]
	return "%04d-%02d-%02d %02d:%02d:%02d" % [t["year"], t["month"], t["day"], t["hour"], t["minute"], t["second"]]


func _write_results(version: int, runs: int, stamp: String, entries: Array, summary: Dictionary):
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(RESULTS_DIR))
	var path := "%s/detective_v%d_%s.json" % [RESULTS_DIR, version, stamp]
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
	var path := RESULTS_DIR + "/detective_summary.md"
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
		file.store_line("# Detective NPC Eval Summary")
		file.store_line("")
		file.store_line("Time per question is API call time including regenerations; the 5s pacing waits and 429 backoffs are excluded.")
		file.store_line("")
		file.store_line("Accuracy excludes questions that ended in an API error; those are counted in the Errors column.")
		file.store_line("")
		file.store_line("| " + " | ".join(PackedStringArray(columns)) + " |")
		file.store_line("| " + " | ".join(PackedStringArray(separator)) + " |")
	var cells: Array = [_timestamp(false)]
	cells.append_array(_row_cells(version, runs, summary))
	file.store_line("| " + " | ".join(PackedStringArray(cells)) + " |")
	file.close()
	print("Updated " + path)
