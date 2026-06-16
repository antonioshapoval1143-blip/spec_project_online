extends Area2D

@export var finish: Control
@export var d_scores := 100
@export var M1 := 0
@export var M2 := 0
@export var M3 := 0
var current_prog = FileAccess.open("user://current_prog", FileAccess.READ).get_var()

func _ready():
	connect("body_entered", Callable(self, "_demo_finish"))

func _demo_finish(body):
	if body.name == "Player":
		Scores.add_score(100)
		var file = FileAccess.open("user://temp_score", FileAccess.READ)
		var scores = file.get_var()
		Scores.end_save(scores)
		var fM1 = current_prog.M1
		var fM2 = current_prog.M2
		var fM3 = current_prog.M3
		if M1 == 1:
			fM1 = 1
		if M2 == 1:
			fM2 = 1
		if M3 == 1:
			fM3 = 1
		var new_current_prog = {
			"M1": fM1,
			"M2": fM2,
			"M3": fM3,
			"M4": 0
		}
		FileAccess.open("user://current_prog", FileAccess.WRITE).store_var(new_current_prog)
		finish.visible = true
		get_tree().paused = !get_tree().paused
		queue_free()
