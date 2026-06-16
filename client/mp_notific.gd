extends Control

var player_who_left = FileAccess.open("user://rpl_data.txt", FileAccess.READ).get_var().others_nick

func _ready() -> void:
	$Control/Label.text = player_who_left

func _on_button_pressed() -> void:
	DirAccess.remove_absolute("user://rpl_data.txt")
	DirAccess.remove_absolute("user://mp_lobby_status")
	DirAccess.remove_absolute("user://winner")
	get_tree().paused = !get_tree().paused
	OnlineMode.disconnect_player()
	get_tree().change_scene_to_file("res://mp_menu.tscn")
