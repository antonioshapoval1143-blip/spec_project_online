extends Node2D

@export var damage: int = 15
@onready var area: Area2D = $Area2D
@onready var animation_player = $AnimatedSprite2D

func _ready():
	area.body_entered.connect(_on_body_entered)
	if animation_player:
		animation_player.play("default")
	
	if animation_player:
		await animation_player.animation_finished
		queue_free()
	else:
		queue_free()

func _on_body_entered(body: Node2D):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage, global_position - body.global_position)
