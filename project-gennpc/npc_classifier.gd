extends Node

signal classification_completed(npc_id: String, matched_id: String, response_text: String)
signal classification_failed(npc_id: String, error_text: String)

var npcs = {
	"hunter": {
		"name": "Daren",
		"candidates": [
			{"id": "forest_animals", "description": "wants to ask about strange behavior of animals in the forest", "response_text": "The animals in the forest have been acting strange. Deer, foxes, all of them keep coming toward the village. That doesn't usually happen."},
			{"id": "hunting_tips", "description": "wants to ask for hunting tips or advice", "response_text": "Watch which way the wind is blowing. Check if the footprints are new or old. That's most of it."},
			{"id": "smalltalk", "description": "just wants to make small talk, like about the weather", "response_text": "The weather's strange lately. It should be getting colder by now, but it isn't."}
		]
	},
	"miner": {
		"name": "Kor",
		"candidates": [
			{"id": "cave_rumor", "description": "wants to ask about strange rumors from the abandoned mine", "response_text": "People say there are strange noises deep in the old mine. Some workers are too scared to go in."},
			{"id": "equipment", "description": "wants to ask about mining equipment or tools", "response_text": "You have to sharpen the pickaxe often. If you don't, you waste a lot of effort."},
			{"id": "smalltalk", "description": "wants to ask if the mining work is hard or tiring", "response_text": "It is tiring work. But I'm used to it by now."}
		]
	}
}

var api_key: String = ""
var http_request: HTTPRequest
var current_npc_id: String = ""

func _ready():
	_load_api_key()
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)


func get_npc_name(npc_id: String) -> String:
	return npcs[npc_id].name


func _load_api_key():
	var file = FileAccess.open("res://.env", FileAccess.READ)
	if file == null:
		push_error(".env file not found. Make sure it's in the project root.")
		return
	while not file.eof_reached():
		var line = file.get_line()
		if line.begins_with("GEMINI_API_KEY="):
			api_key = line.substr("GEMINI_API_KEY=".length()).strip_edges()
	file.close()


func classify_input(npc_id: String, player_text: String):
	if api_key == "":
		classification_failed.emit(npc_id, "API key is empty. Check the .env file.")
		return

	if not npcs.has(npc_id):
		classification_failed.emit(npc_id, "Unknown npc_id: " + npc_id)
		return

	current_npc_id = npc_id
	var candidates = npcs[npc_id].candidates

	var options_text = ""
	var id_list_text = ""
	for c in candidates:
		options_text += "- %s: %s\n" % [c.id, c.description]
		id_list_text += c.id + ", "
	id_list_text += "none"

	var prompt = "You are a strict classifier for a game dialogue system.\n"
	prompt += "A player typed this sentence: \"%s\"\n\n" % player_text
	prompt += "Which ONE of these candidate actions does it best match?\n"
	prompt += options_text + "\n"
	prompt += "If it clearly matches none of them, or is too ambiguous, answer exactly: none\n"
	prompt += "If the sentence is only a greeting or a meaningless filler word (like hello, hi, hey, okay, cool, nice, thanks) and does not mention any specific topic from the candidates above, answer exactly: none\n"
	prompt += "A candidate whose description is small talk (like weather, or whether the work is tiring) only applies when the sentence directly brings up that exact topic. Any other topic (food, other people, unrelated objects, etc.), no matter how casual the tone, must be classified as none. For example, \"What's your favorite food?\" is none, not smalltalk.\n"
	prompt += "Respond with ONLY one id from this list: %s\n" % id_list_text
	prompt += "No explanation, no extra words, just the id."

	var url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent"
	var headers = [
		"Content-Type: application/json",
		"x-goog-api-key: " + api_key
	]
	var body = JSON.stringify({
		"contents": [{"parts": [{"text": prompt}]}]
	})

	http_request.request(url, headers, HTTPClient.METHOD_POST, body)


func _on_request_completed(result, response_code, headers, body):
	var text_body = body.get_string_from_utf8()

	if response_code != 200:
		classification_failed.emit(current_npc_id, "Error response (%d): %s" % [response_code, text_body])
		return

	var json = JSON.parse_string(text_body)
	if json and json.has("candidates"):
		var answer = json["candidates"][0]["content"]["parts"][0]["text"].strip_edges()
		var response_text = _find_response_text(current_npc_id, answer)
		classification_completed.emit(current_npc_id, answer, response_text)
	else:
		classification_failed.emit(current_npc_id, "Failed to parse response, raw: " + text_body)


func _find_response_text(npc_id: String, matched_id: String) -> String:
	for c in npcs[npc_id].candidates:
		if c.id == matched_id:
			return c.response_text
	return ""
