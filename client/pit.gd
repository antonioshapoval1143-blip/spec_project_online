extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	pass # Replace with function body.

func _on_body_entered(body):
	if body.is_in_group("player"):
		#body.take_damage(101)
		body.die()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
