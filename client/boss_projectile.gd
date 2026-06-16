extends CharacterBody2D

@export var speed: float = 200.0
@export var damage: int = 10
@export var health: int = 10
@export var death_effect_scene: PackedScene

@export var rotation_speed: float = 5.0

var target: Node2D

func _ready():
	$AnimatedSprite2D.play("default")

func _physics_process(delta):
	if target and is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		
		rotation = lerp_angle(rotation, direction.angle(), rotation_speed * delta)
		
		velocity = direction * speed
		move_and_slide()
		
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider and is_instance_valid(collider) and collider.is_in_group("player") and collider.has_method("take_damage"):
				collider.take_damage(damage, global_position - collider.global_position)
				$AnimatedSprite2D.play("destroyed")
				await $AnimatedSprite2D.animation_finished
				#spawn_death_effect()
				queue_free()
				break

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		spawn_death_effect()
		queue_free()

func spawn_death_effect() -> void:
	if death_effect_scene:
		var effect = death_effect_scene.instantiate()
		effect.global_position = global_position
		get_tree().current_scene.add_child(effect)
