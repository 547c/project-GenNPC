extends Node

# ==== 목업 flag 후보 (실험용 가짜 데이터 — project-jrpg 진짜 flag 아님) ====
var candidates = [
	{"id": "go_eat", "description": "플레이어가 밥을 먹으러 가고 싶어함, 배고프다고 말함"},
	{"id": "go_home", "description": "플레이어가 집에 가고 싶어함, 쉬고 싶다고 말함"},
	{"id": "go_movie", "description": "플레이어가 영화를 보러 가고 싶어함, 심심하다고 말함"}
]

var api_key: String = ""
var http_request: HTTPRequest

func _ready():
	_load_api_key()
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

	# 테스트용 입력 — 나중에 실제 텍스트 입력창으로 바꿀 것
	var test_input = "아 배고프다"
	print("테스트 입력: ", test_input)
	classify_input(test_input)


func _load_api_key():
	var file = FileAccess.open("res://.env", FileAccess.READ)
	if file == null:
		push_error(".env 파일을 못 찾았어. project-GenNPC 폴더 루트에 있는지 확인해줘.")
		return
	while not file.eof_reached():
		var line = file.get_line()
		if line.begins_with("GEMINI_API_KEY="):
			api_key = line.substr("GEMINI_API_KEY=".length()).strip_edges()
	file.close()


func classify_input(player_text: String):
	if api_key == "":
		push_error("API 키가 비어있어. .env 파일 확인해줘.")
		return

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
	print("응답 코드: ", response_code)
	var text_body = body.get_string_from_utf8()

	if response_code != 200:
		print("에러 응답: ", text_body)
		return

	var json = JSON.parse_string(text_body)
	if json and json.has("candidates"):
		var answer = json["candidates"][0]["content"]["parts"][0]["text"]
		print("AI 분류 결과 -> ", answer.strip_edges())
	else:
		print("응답 파싱 실패, 원문: ", text_body)
