extends Control

var player = FileAccess.open("user://login", FileAccess.READ).get_var()
var player_id = int(player.player_id)
var player_nickname = player.nickname
var scores = int()

func _ready() -> void:
	if FileAccess.file_exists("user://current_score"):
		scores = int(FileAccess.open("user://current_score", FileAccess.READ).get_var())
	$MenuBar/Nickname.text = player_nickname
	$MenuBar2/Scores.text = str(scores)
	if await DbConnection.is_server_online():
		var check_record = bool((await DbConnection.does_it_have_score(player_id)).items[0].check_exist)
		if check_record == true:
			var record = int((await DbConnection.get_player_score(player_id)).items[0].score)
			$MenuBar4/Scores.text = str(record)
		else:
			$MenuBar4/Scores.text = str(0)
	else:
		$MenuBar4/Scores.text = "You're offline"


func _on_load_game_pressed() -> void:
	get_tree().change_scene_to_file("res://load_game.tscn")


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")


func _on_delete_prof_pressed() -> void:
	$MenuBar3/LoadGame.disabled = true
	$MenuBar3/MainMenu.disabled = true
	$MenuBar3/DeleteProf.disabled = true
	$ConfirmationDialog.visible = true


func _on_confirmation_dialog_confirmed() -> void:
	if await DbConnection.is_server_online():
		DbConnection.delete_prof(player_id)
		DirAccess.remove_absolute("user://login")
		get_tree().change_scene_to_file("res://menu.tscn")
	else:
		$Error.visible = true
		return


func _on_confirmation_dialog_canceled() -> void:
	$MenuBar3/LoadGame.disabled = false
	$MenuBar3/MainMenu.disabled = false
	$MenuBar3/DeleteProf.disabled = false


func _on_logout_pressed() -> void:
	DirAccess.remove_absolute("user://login")
	get_tree().change_scene_to_file("res://menu.tscn")


func _on_show_scores_pressed() -> void:
	var networkcheck = await DbConnection.is_server_online()
	
	if networkcheck:
		get_tree().change_scene_to_file("res://leaderscores.tscn")
	
	else:
		$Error.visible = true
		return


func _on_multiplayer_pressed() -> void:
	get_tree().change_scene_to_file("res://mp_menu.tscn")
	pass # Replace with function body.
