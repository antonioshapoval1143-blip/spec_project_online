extends Control

var del_opt = 0
var player_id = int(FileAccess.open("user://login", FileAccess.READ).get_var().player_id)

func load_game(slot: int):
	var prog
	var scores
	if $CheckButton.button_pressed == true:
		if FileAccess.file_exists("user://game_save"+str(slot)):
			var load_save = FileAccess.open("user://game_save"+str(slot), FileAccess.READ).get_var()
			prog = load_save.current_progress
			scores = load_save.current_score
		else:
			#get_tree().paused = !get_tree().paused
			$Error.dialog_text = "No save here."
			$Error.visible = true
			return
	else:
		var res = await DbConnection.get_player_saves(str(player_id), int(slot))
		if await DbConnection.is_server_online():
			if res.items.is_empty() or res.items.size() == 0:
				#get_tree().paused = !get_tree().paused
				$Error.dialog_text = "No save here"
				$Error.visible = true
				return
			else:
				var load_save = res.items[0]
				prog = JSON.parse_string(load_save.save_data)
				scores = load_save.current_score
		else:
			$Error.dialog_text = "You`re offline.\nCheck connection"
			$Error.visible = true
			return
			
	FileAccess.open("user://current_score", FileAccess.WRITE).store_var(scores)
	FileAccess.open("user://current_prog", FileAccess.WRITE).store_var(prog)	
	get_tree().change_scene_to_file("res://next_levs.tscn")

func _on_button_pressed() -> void:
	#var test = FileAccess.open("user://login", FileAccess.READ)
	#print(test.get_var())
	load_game(1)
	
	pass # Replace with function body.


func _on_button_2_pressed() -> void:
	load_game(2)
	pass # Replace with function body.


func _on_button_3_pressed() -> void:
	load_game(3)
	pass # Replace with function body.


func _on_button_4_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
	pass # Replace with function body.


func _on_button_3_button_down() -> void:
	del_opt = 1
	$Control/Button2.button_pressed = false
	$Control/Button.button_pressed = false


func _on_button_2_button_down() -> void:
	del_opt = 2
	$Control/Button3.button_pressed = false
	$Control/Button.button_pressed = false


func _on_button_button_down() -> void:
	del_opt = 3
	$Control/Button2.button_pressed = false
	$Control/Button3.button_pressed = false


func _on_button_5_pressed() -> void:
	if del_opt == 1:
		if $CheckButton.button_pressed == true:
			DirAccess.remove_absolute("user://game_save"+str(del_opt))
		else:
			DbConnection.delete_save(player_id, del_opt)
	elif del_opt == 2:
		if $CheckButton.button_pressed == true:
			DirAccess.remove_absolute("user://game_save"+str(del_opt))
		else:
			DbConnection.delete_save(player_id, del_opt)
	elif del_opt == 3:
		if $CheckButton.button_pressed == true:
			DirAccess.remove_absolute("user://game_save"+str(del_opt))
		else:
			DbConnection.delete_save(player_id, del_opt)
	after_delete()

func turn_off():
	$Button.disabled = true
	$Button2.disabled = true
	$Button3.disabled = true
	$Button4.disabled = true
	$Button5.disabled = true
	$CheckButton2.disabled = true

func turn_on():
	$Button.disabled = false
	$Button2.disabled = false
	$Button3.disabled = false
	$Button4.disabled = false
	$Button5.disabled = false
	$CheckButton2.disabled = false

func after_delete():
	$CheckButton2.button_pressed = false
	turn_on()
	$Control.visible = false
	$Button5.visible = false
	$Button4.visible = true

func _on_check_button_2_pressed() -> void:
	if $CheckButton2.button_pressed == true:
		$Button.disabled = true
		$Button2.disabled = true
		$Button3.disabled = true
		$Control.visible = true
		$Button5.visible = true
		$Button4.visible = false
	else:
		after_delete()

func _on_error_confirmed() -> void:
	turn_on()
	#get_tree().paused = !get_tree().paused
	pass # Replace with function body.
