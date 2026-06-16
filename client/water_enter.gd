extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)
	pass # Replace with function body.

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.JUMP_VELOCITY == -800:
			body.JUMP_VELOCITY = -900
			print(body.JUMP_VELOCITY)
		else:
			body.JUMP_VELOCITY = -800
			print(body.JUMP_VELOCITY)
			
