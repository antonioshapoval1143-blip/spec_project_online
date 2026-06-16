extends Control


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://create_or_join.tscn")
	pass # Replace with function body.


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://mp_history.tscn")
	pass # Replace with function body.


func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
	pass # Replace with function body.
