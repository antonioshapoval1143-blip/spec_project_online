extends Control

var winner := FileAccess.open("user://winner", FileAccess.READ).get_as_text()

func _ready() -> void:
	$Control/Label.text = winner


func _on_button_pressed() -> void:
	DirAccess.remove_absolute("user://rpl_data.txt")
	DirAccess.remove_absolute("user://mp_lobby_status")
	DirAccess.remove_absolute("user://winner")
	OnlineMode.disconnect_player()
	get_tree().change_scene_to_file("res://mp_menu.tscn")
	pass # Replace with function body.
