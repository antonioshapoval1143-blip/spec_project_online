extends Control

var your_player_id := int(FileAccess.open("user://login", FileAccess.READ).get_var().player_id)

func _ready() -> void:
	OnlineMode.start_the_server()

func _on_button_pressed() -> void:
	OnlineMode.create_lobby()
	save_status(1)
	get_tree().change_scene_to_file("res://mp_lobby.tscn")


func _on_button_2_pressed() -> void:
	on_b2_pressed()
	

func on_b2_pressed():
	var code = $TextEdit.text
	OnlineMode.join_lobby(code)
	await get_tree().create_timer(0.5).timeout
	print(OnlineMode.join_failed)
	if OnlineMode.join_failed == true:
		$AcceptDialog.visible = true
	elif OnlineMode.join_failed == false:
		save_status(0)
		OnlineMode.send_profile_id(str(your_player_id))
		get_tree().change_scene_to_file("res://mp_lobby.tscn")

func save_status(n):
	if n == 1:
		FileAccess.open("user://mp_lobby_status", FileAccess.WRITE).store_string("cr")
	else:
		FileAccess.open("user://mp_lobby_status", FileAccess.WRITE).store_string("jo")


func _on_accept_dialog_confirmed() -> void:
	OnlineMode.join_failed = false


func _on_text_edit_text_submitted(_new_text: String) -> void:
	on_b2_pressed()
