extends Node

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

var test_npc_id = "miner"
var test_input = "Is something wrong in the mine?"

var api_key: String = ""
var http_request: HTTPRequest
var current_npc_id: String = ""

func _ready():
	_load_api_key()
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

	print("Test NPC: ", test_npc_id, " | Test input: ", test_input)
	classify_input(test_npc_id, test_input)


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
		push_error("API key is empty. Check the .env file.")
		get_tree().quit(1)
		return

	if not npcs.has(npc_id):
		push_error("Unknown npc_id: " + npc_id)
		get_tree().quit(1)
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
	prompt += "Respond with ONLY one id from this list: %s\n" % id_list_text
	prompt += "No explanation, no extra words, just the id."

	var url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent"
	var headers = [
		"Content-Type: application/json",
		"x-goog-api-key: " + api_key
	]
	var body = JSON.stringify({
		"contents": [{"parts": [{"text": prompt}]}]
	})

	http_request.request(url, headers, HTTPClient.METHOD_POST, body)


func _on_request_completed(result, response_code, headers, body):
	print("Response code: ", response_code)
	var text_body = body.get_string_from_utf8()

	if response_code != 200:
		print("Error response: ", text_body)
		get_tree().quit(1)
		return

	var json = JSON.parse_string(text_body)
	if json and json.has("candidates"):
		var answer = json["candidates"][0]["content"]["parts"][0]["text"].strip_edges()
		print("AI classification -> ", answer)
		_print_response(current_npc_id, answer)
	else:
		print("Failed to parse response, raw: ", text_body)

	get_tree().quit()


func _print_response(npc_id: String, matched_id: String):
	var npc = npcs[npc_id]
	for c in npc.candidates:
		if c.id == matched_id:
			print("[%s] %s: %s" % [npc_id, npc.name, c.response_text])
			return
	print("[%s] %s: (no response defined for id '%s')" % [npc_id, npc.name, matched_id])
