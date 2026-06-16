extends Control

var current_lvl = FileAccess.open("user://cur_level", FileAccess.READ).get_as_text()

# Called when the node enters the scene tree for the first time.
func _ready():
	$AspectRatioContainer/AnimatedSprite2D.play("default")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_button_pressed():
	get_tree().change_scene_to_file(current_lvl)
	pass # Replace with function body.


func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")
	pass # Replace with function body.
