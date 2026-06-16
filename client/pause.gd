extends Control

func _on_returt_pressed() -> void:
	$".".visible = false
	get_tree().paused = !get_tree().paused
	pass # Replace with function body.


func _on_bt_m_pressed() -> void:
	get_tree().paused = !get_tree().paused
	Scores.clean_temp()
	get_tree().change_scene_to_file("res://menu.tscn")
	pass # Replace with function body.
