extends Node

signal connected_to_server()
signal connection_failed()
signal joined_room(room_id: String)
signal player_ready_updated(player_id: String, ready: bool)
signal player_joined(player_id: String)
signal player_left(player_id: String)
signal game_state_updated(other_player_data: Dictionary)
signal start_game()
signal hp_updated(player_id: String, hp: int)
signal remote_shot(data: Dictionary)
signal bullet_spawned(data: Dictionary)
signal other_player_prof_id(profile_id: String)
signal player_died(player_id)

var socket = WebSocketPeer.new()
var connected := false
var my_player_id := ""
var current_room_id := ""
var other_player_data := {}
var room_code := ""
var join_failed = false

var server_url := "ws://25.7.66.224:8765"

func connect_to_server() -> void:
	var err = socket.connect_to_url(server_url)
	if err != OK:
		connection_failed.emit()

func send_ready_state(ready: bool):
	if not connected:
		return

	socket.send_text(JSON.stringify({
		"type": "player_ready",
		"ready": ready
	}))

func send_bullet_spawn(pos: Vector2, dir: Vector2):
	if not connected: return
	socket.send_text(JSON.stringify({
		"type": "bullet_spawn",
		"x": pos.x,
		"y": pos.y,
		"dir_x": dir.x,
		"dir_y": dir.y
	}))
	print("bullet")

func send_bullet_hit(target_player_id: String, hit_position: Vector2):
	if not connected: return
	socket.send_text(JSON.stringify({
		"type": "bullet_hit",
		"target_id": target_player_id,
		"x": hit_position.x,
		"y": hit_position.y
	}))
	print("hit")

#func _ready():
func start_the_server():
	set_process(true)
	
	connect_to_server()

func _process(_delta):
	socket.poll()
	var state = socket.get_ready_state()
	
	if state == WebSocketPeer.STATE_OPEN:
		if not connected:
			connected = true
			connected_to_server.emit()
		
		while socket.get_available_packet_count() > 0:
			_handle_message()
			
	elif state == WebSocketPeer.STATE_CLOSED and connected:
		connected = false
		
func create_lobby():
	socket.send_text(JSON.stringify({
		"type": "create_lobby"
	}))
	
func join_lobby(code: String):
	socket.send_text(JSON.stringify({
		"type": "join_lobby",
		"room_code": code
	}))
	
func disconnect_player():
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.close()
	
	connected = false
	
func send_profile_id(profile_id: String):
	if not connected:
		return
	
	socket.send_text(JSON.stringify({
		"type": "player_profile",
		"profile_id": profile_id
	}))

func emit_player_died(player_id):
	player_died.emit(player_id)

func _handle_message():

	var packet = socket.get_packet().get_string_from_utf8()

	#print("RAW: ", packet)

	var msg = JSON.parse_string(packet)

	if msg == null:
		print("JSON parse failed")
		return

	if not msg.has("type"):
		print("No type")
		return

	match msg["type"]:

		"connected":
			my_player_id = str(msg["player_id"])
			print("Connected! ID: ", my_player_id)

		"lobby_created":
			room_code = msg["room_code"]
			print("Lobby code: ", room_code)

		"join_failed":
			print("Join failed: ", msg["reason"])
			join_failed = true

		"player_ready":
			player_ready_updated.emit(
				str(msg["player_id"]),
				msg["ready"]
			)
			
		"player_hit":
			hp_updated.emit(
				str(msg["player_id"]),
				int(msg["hp"])
			)
			
		"player_shot":
			remote_shot.emit(msg)

		"start_game":
			start_game.emit()
			
		"bullet_spawn":
			bullet_spawned.emit(msg)

		"room_joined":
			current_room_id = str(msg["room_id"])
			joined_room.emit(current_room_id)

		"player_joined":
			player_joined.emit(str(msg["player_id"]))

		"player_left":
			player_left.emit(str(msg["player_id"]))
			print("left")
			other_player_data.clear()

		"game_state":
			if str(msg["player_id"]) != my_player_id:
				other_player_data = msg
				game_state_updated.emit(other_player_data)
		
		"player_profile":
			var prof_id = msg["profile_id"]
			other_player_prof_id.emit(prof_id)
			#print("Remote profile: ", other_player_prof_id)
			
		"player_died":
			emit_player_died(msg["player_id"])


# ───── Відправка даних ─────
func send_position(pos: Vector2, velocity: Vector2, anim: String, flip_h: bool, is_shooting: bool) -> void:
	if not connected: return
	var data = {
		"type": "update_position",
		"x": pos.x,
		"y": pos.y,
		"vx": velocity.x,
		"vy": velocity.y,
		"anim": anim,
		"flip_h": flip_h,
		"shooting": is_shooting
	}
	socket.send_text(JSON.stringify(data))

#func send_shoot(pos: Vector2, direction: Vector2) -> void:
	#if not connected: return
	#socket.send_text(JSON.stringify({
		#"type": "shoot",
		#"x": pos.x,
		#"y": pos.y,
		#"dir_x": direction.x,
		#"dir_y": direction.y
	#}))

# Кімнати
func create_or_join_room() -> void:
	socket.send_text(JSON.stringify({"type": "join_room"}))
