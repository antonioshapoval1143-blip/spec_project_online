extends Node2D

#@export var warning_duration: float = 1.0
@onready var animation_player = $AnimatedSprite2D

signal warning_finished

func _ready():
	if animation_player:
		animation_player.play("default")
		await $AnimatedSprite2D.animation_finished
		#await get_tree().create_timer(warning_duration).timeout
		emit_signal("warning_finished")
		queue_free()
	else:
		emit_signal("warning_finished")
		queue_free()
