extends Button



func _on_pressed() -> void:
	
	#get_tree().paused = !get_tree().paused
	Scores.clean_temp()
	get_tree().change_scene_to_file("res://menu.tscn")
