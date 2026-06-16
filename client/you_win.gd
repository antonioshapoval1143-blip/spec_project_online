extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var file = FileAccess.open("user://current_score", FileAccess.READ)
	var scores = file.get_var()
	$Label3.text = str(scores)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	pass


func _on_button_pressed():
	get_tree().change_scene_to_file("res://demo_level.tscn")
	pass # Replace with function body.


func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")
	pass # Replace with function body.


func _on_test_pressed():
	var data_1 = FileAccess.open("user://login", FileAccess.READ)
	var player_id = data_1.get_var().player_id
	DbConnection.save_scores(player_id, int($Label3.text))
	
