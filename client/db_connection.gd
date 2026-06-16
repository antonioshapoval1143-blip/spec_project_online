extends Node

@onready var http: HTTPRequest = HTTPRequest.new()

func _ready() -> void:
	add_child(http)
	print("DB connection node ready")


# ─────────────────────────────────────────────
# Головні методи
# ─────────────────────────────────────────────

func login(nickname: String, password_hash: String):
	var payload = {
		"num": 1,
		"str1": nickname,
		"str2": password_hash
	}
	var response = await _request(payload, HTTPClient.METHOD_GET)
	return response


func fetch_leaderboard():
	var payload = {
		"num": 3,
		"str1": "_",
		"str2": "_"
	}
	var response = await _request(payload, HTTPClient.METHOD_GET)
	return response


func get_player_saves(player_id: String, save_num: int):
	var payload = {
		"num": 2,
		"str1": player_id,
		"str2": str(save_num)
	}
	var response = await _request(payload, HTTPClient.METHOD_GET)
	return response


func check_saves(player_id: int, save_num: int):
	var payload = {
		"num": 5,
		"str1": player_id,
		"str2": save_num
	}
	var response = await DbConnection._request(payload, HTTPClient.METHOD_GET)
	return response

func get_player_score(player_id: int):
	var payload = {
		"num": 4,
		"str1": player_id, 
		"str2": "_"
	}
	var response = await DbConnection._request(payload, HTTPClient.METHOD_GET)
	return response

func get_player_nickname(player_id: int):
	var payload = {
		"num": 7,
		"str1": player_id, 
		"str2": "_"
	}
	var response = await DbConnection._request(payload, HTTPClient.METHOD_GET)
	return response

func mp_results(filter: int):
	var player_id = int(FileAccess.open("user://login", FileAccess.READ).get_var().player_id)
	var payload = {
		"num": 8,
		"str1": filter, 
		"str2": player_id
	}
	var response = await DbConnection._request(payload, HTTPClient.METHOD_GET)
	return response

func does_it_have_score(player_id: int):
	var payload = {
		"num": 6,
		"str1": player_id, 
		"str2": "_"
	}
	var response = await DbConnection._request(payload, HTTPClient.METHOD_GET)
	print(response)
	return response

func register(nickname: String, password_hash: String) -> Dictionary:
	var payload = {
		"num": 1,
		"str1": nickname,
		"str2": password_hash,
		"str3": "_",
		"str4": "_"
	}
	var response = await _request(payload, HTTPClient.METHOD_POST)
	return response


func save_scores(player_id: int, scores: int) -> Dictionary:
	var payload = {
		"num": 2,
		"str1": player_id,
		"str2": scores,
		"str3": "_",
		"str4": "_"
	}
	var response = await _request(payload, HTTPClient.METHOD_POST)
	return response


func save_game(player_id: String, save_num: int, save_data: String, score: int) -> Dictionary:
	var payload = {
		"num": 3,
		"str1": player_id,
		"str2": str(save_num),
		"str3": save_data,
		"str4": str(score)
	}
	var response = await _request(payload, HTTPClient.METHOD_POST)
	return response

func mp_result(player1_id: int, player2_id: int, winner: int) -> Dictionary:
	var payload = {
		"num": 4,
		"str1": player1_id,
		"str2": player2_id,
		"str3": winner,
		"str4": "_"
	}
	var response = await _request(payload, HTTPClient.METHOD_POST)
	return response

func new_score(player_id: int, scores: int):
	var payload = {
		"num": 2,
		"str1": player_id,
		"str2": scores,
		"str3": "_",
		"str4": "_"
	}
	var response = await _request(payload, HTTPClient.METHOD_PATCH)
	print(response)
	return response


func edit_save(player_id: int, slot: int, data: String, scores: int):
	var payload = {
		"num": 1,
		"str1": player_id,
		"str2": slot,
		"str3": data,
		"str4": scores
	}
	var response = await _request(payload, HTTPClient.METHOD_PATCH)
	return response


func delete_prof(player_id: int):
	var payload = {
		"num": 1,
		"str1": player_id,
		"str2": "_"
	}
	var response = await _request(payload, HTTPClient.METHOD_DELETE)
	return response


func delete_save(player_id: int, save_num: int):
	var payload = {
		"num": 2,
		"str1": player_id,
		"str2": save_num
	}
	var response = await _request(payload, HTTPClient.METHOD_DELETE)
	return response

# ─────────────────────────────────────────────
# Один універсальний метод
# ─────────────────────────────────────────────


func _request(payload: Dictionary, method: HTTPClient.Method) -> Dictionary:
	#await HTTPRequest.request_completed
	var json_string = JSON.stringify(payload)
	var headers = ["Content-Type: application/json"]
	#var url = "http://127.0.0.1:5000/api"
	#var url = "http://25.7.67.45:5000/api"
	var url = "http://25.7.66.224:5000/api"

	var err = http.request(url, headers, method, json_string)
	if err != OK:
		printerr("Не вдалося запустити запит: ", err)
		return {"error": "request_init_failed", "code": err, "message": "Не вдалося запустити HTTP запит"}

	var array: Array = await http.request_completed
	var result: int = array[0]
	var code: int = array[1]
	var body: PackedByteArray = array[3]

	if result != HTTPRequest.RESULT_SUCCESS:
		printerr("Запит неуспішний: ", result)
		return {"error": "connection_error", "result": result, "message": "Проблема з'єднання з сервером"}

	if code < 200 or code >= 300:
		printerr("HTTP помилка: ", code)
		return {"error": "http_error", "status": code, "message": "Сервер повернув помилку " + str(code)}

	var text = body.get_string_from_utf8()
	var data = JSON.parse_string(text)
	
	if data == null:
		printerr("Невалідний JSON:\n", text)
		return {"error": "invalid_json", "raw_response": text, "message": "Сервер повернув некоректний JSON"}

	
	if data is Dictionary:
		return data
	elif data is Array:
		return {
			"items": data
		}
	else:
		return {"error": "unexpected_type", "received": type_string(typeof(data))}


func is_server_online() -> bool:
	var ping = HTTPRequest.new()
	add_child(ping)
	ping.timeout = 4.0                     # максимум 4 секунди

	#var err = ping.request("http://127.0.0.1:5000/api",
	var err = ping.request("http://25.7.66.224:5000/api",
		["Content-Type: application/json"],
		HTTPClient.METHOD_GET,
		JSON.stringify({"num": 0, "str1": "ping", "str2": "ping"}))

	if err != OK:
		ping.queue_free()
		return false
		
	var result = await ping.request_completed
	ping.queue_free()
	
	# Якщо хоча б отримали відповідь від сервера (навіть 404, 500 тощо) — сервер онлайн
	return result[0] == HTTPRequest.RESULT_SUCCESS
