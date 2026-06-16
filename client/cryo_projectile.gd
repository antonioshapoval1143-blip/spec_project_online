extends CharacterBody2D

@export var speed := 680.0
@export var life_time := 5.5
@export var damage := 7
@export var extra_damage := 2
@export var freeze_duration_min := 1.2
@export var freeze_duration_max := 2.0

var direction: Vector2 = Vector2.RIGHT

func _ready():
	$AnimatedSprite2D.play("idle")
	rotation = direction.angle()
	await get_tree().create_timer(life_time).timeout
	queue_free()


func _physics_process(delta):
	var motion = direction * speed * delta
	var collision = move_and_collide(motion)
	
	if collision:
		var collider = collision.get_collider()
		if collider and collider.is_in_group("enemy"):
			_apply_cryo(collider)
		$AnimatedSprite2D.play("at_hit")
		#await $AnimatedSprite2D.animation_finished
		queue_free()


func _apply_cryo(enemy: Node):
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)
		
		if enemy.is_in_group("cryogenic"):
			enemy.take_damage(extra_damage)
			
			var duration = randf_range(freeze_duration_min, freeze_duration_max)
			
			if enemy.has_method("apply_slow") or enemy.has_method("apply_freeze"):
				if enemy.has_method("apply_freeze"):
					enemy.apply_freeze(duration)
				elif enemy.has_method("apply_slow"):
					enemy.apply_slow(0.0, duration)     # 0.0 = повна зупинка
			elif "velocity" in enemy and "speed" in enemy:

				var original_speed = enemy.speed
				enemy.speed = 0
				await get_tree().create_timer(duration).timeout
				if is_instance_valid(enemy):
					enemy.speed = original_speed
