extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	if await DbConnection.is_server_online():
		print("yes")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_pressed():
	var new = 0
	Scores.score_save(new)
	Scores.end_save(new)
	var new_game = "res://demo_level.tscn"
	FileAccess.open("user://cur_level", FileAccess.WRITE).store_string(new_game)
	DirAccess.remove_absolute("user://current_prog")
	get_tree().change_scene_to_file(new_game)


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://load_game.tscn")
	pass # Replace with function body.


func _on_button_3_pressed() -> void:
	#var player_data = FileAccess.open("user://login", FileAccess.READ).get_var()
	if FileAccess.file_exists("user://login"):
		get_tree().change_scene_to_file("res://profile.tscn")
	else:
		get_tree().change_scene_to_file("res://Login.tscn")
	 # Replace with function body.
