extends Control

@onready var ready_checkbox = $CheckBox

#@onready var status1 = $VBoxContainer/Player1Status
#@onready var status2 = $VBoxContainer/Player2Status

var player_ready := false
var other_ready := false
var local_player_id := int(FileAccess.open("user://login", FileAccess.READ).get_var().player_id)
var player_nickname := str(FileAccess.open("user://login", FileAccess.READ).get_var().nickname)
var mp_status = FileAccess.open("user://mp_lobby_status", FileAccess.READ).get_as_text()

func _ready():
	if mp_status != "cr":
		$Control.visible = false
	$CheckBox.toggled.connect(_on_ready_toggled)
	#OnlineMode.send_profile_id(str(local_player_id))
	$Label.text = player_nickname
	$ColorRect1.color = Color(1.0, 0.0, 0.0)
	$ColorRect2.color = Color(1.0, 0.0, 0.0)
	
	OnlineMode.other_player_prof_id.connect(_on_profile_received)

	OnlineMode.player_ready_updated.connect(_on_player_ready_updated)
	OnlineMode.start_game.connect(_on_start_game)
	


func _on_profile_received(profile_id):
	print("Received profile ID: ", int(profile_id))
	var other_player_data = await DbConnection.get_player_nickname(int(profile_id))
	print(other_player_data)
	var others_nick = other_player_data.items[0].nickname
	#print(others_nick)
	$Label2.text = others_nick
	print(others_nick)
	FileAccess.open("user://rpl_data.txt", FileAccess.WRITE).store_var({
		"profile_id": profile_id,
		"others_nick": others_nick
	})
	OnlineMode.send_profile_id(str(local_player_id))
	#return profile_id

func _on_ready_toggled(toggled: bool):
	player_ready = toggled

	OnlineMode.send_ready_state(player_ready)

	_update_ui()

func _on_player_ready_updated(player_id: String, ready: bool):
	if player_id != OnlineMode.my_player_id:
		other_ready = ready

	_update_ui()
	

func _process(_delta: float) -> void:
	$Control/code.text = OnlineMode.room_code
	pass

func _update_ui():
	#status1.text = "YOU: READY" if player_ready else "YOU: NOT READY"
	#status2.text = "ENEMY: READY" if other_ready else "ENEMY: NOT READY"
	$ColorRect1.color = Color(0.0, 1.0, 0.0) if player_ready else Color(1.0, 0.0, 0.0)
	$ColorRect2.color = Color(0.0, 1.0, 0.0) if other_ready else Color(1.0, 0.0, 0.0)

func _on_start_game():
	get_tree().change_scene_to_file("res://multiplayer_map.tscn")
