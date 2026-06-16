extends Control

var data = FileAccess.open("user://current_prog", FileAccess.READ).get_var()
var score = int(FileAccess.open("user://current_score", FileAccess.READ).get_var())

func _ready() -> void:
	#print(data)
	#print(score)
	$MenuBar2/Scores.text = str(score)
	score_checking()
	progress()


func score_checking():
	var player_id = int(FileAccess.open("user://login", FileAccess.READ).get_var().player_id)
	var scores = int(FileAccess.open("user://current_score", FileAccess.READ).get_var())
	var networkcheck = await DbConnection.is_server_online()
	await get_tree().create_timer(4).timeout
	if networkcheck:
		var res1 = bool((await DbConnection.does_it_have_score(player_id)).items[0].check_exist)
		await get_tree().create_timer(4).timeout
		print(res1)
		if res1 == false:
			print(player_id)
			print(scores)
			await DbConnection.save_scores(player_id, scores)
		else:
			var record = int((await DbConnection.get_player_score(player_id)).items[0].score)
			if scores > record:
				await DbConnection.new_score(player_id, scores)

func progress():
	if data.M1 == 1:
		$M1.disabled = true
	if data.M2 == 1:
		$M2.disabled = true
	if data.M3 == 1:
		$M3.disabled = true
	if data.M1 and data.M2 and data.M3 == 1:
		$M4.visible = true
		pass

func get_to_lvl(path):
	FileAccess.open("user://cur_level", FileAccess.WRITE).store_string(path)
	get_tree().change_scene_to_file(path)
	

func _on_m_1_pressed() -> void:
	get_to_lvl("res://plant.tscn")
	pass # Replace with function body.


func _on_m_2_pressed() -> void:
	get_to_lvl("res://port.tscn")
	pass # Replace with function body.


func _on_m_3_pressed() -> void:
	get_to_lvl("res://estation.tscn")
	pass # Replace with function body.


func _on_m_4_pressed() -> void:
	pass # Replace with function body.


func _on_load_game_pressed() -> void:
	get_tree().change_scene_to_file("res://load_game.tscn")
	pass # Replace with function body.


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
	pass # Replace with function body.


func _on_save_game_pressed() -> void:
	get_tree().change_scene_to_file("res://save_game.tscn")
	pass # Replace with function body.
