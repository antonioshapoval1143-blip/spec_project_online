extends Control


func save_games(slot: int):
	var current_score = FileAccess.open("user://current_score", FileAccess.READ).get_var()
	var current_progress = FileAccess.open("user://current_prog", FileAccess.READ).get_var()
	if $CheckButton.button_pressed == true:
		var save_game = {
			"current_progress": current_progress,
			"current_score": current_score
		}
		FileAccess.open("user://game_save"+str(slot), FileAccess.WRITE).store_var(save_game)
	else:
		if await DbConnection.is_server_online():
			var player_id = int(FileAccess.open("user://login", FileAccess.READ).get_var().player_id)
			var check_save_exist = bool((await DbConnection.check_saves(player_id, slot)).items[0].check_exist)
			if check_save_exist == false:
				DbConnection.save_game(str(player_id), slot, JSON.stringify(current_progress), current_score)
			else:
				DbConnection.edit_save(player_id, slot, JSON.stringify(current_progress), current_score)
		else:
			$Error.visible = true
			return
	get_tree().change_scene_to_file("res://next_levs.tscn")

func _on_button_pressed() -> void:
	save_games(1)
	pass # Replace with function body.


func _on_button_2_pressed() -> void:
	save_games(2)
	pass # Replace with function body.


func _on_button_3_pressed() -> void:
	save_games(3)
	pass # Replace with function body.


func _on_button_4_pressed() -> void:
	get_tree().change_scene_to_file("res://next_levs.tscn")
	pass # Replace with function body.
