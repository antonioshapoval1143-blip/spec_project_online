extends CharacterBody2D

@export var speed := 750.0
@export var life_time := 5.0
@export var damage := 6
@export var slow_duration_min := 3.0
@export var slow_duration_max := 4.0
@export var extra_damage := 3

var direction: Vector2 = Vector2.RIGHT

func _ready():
	$AnimatedSprite2D.play("default")
	rotation = direction.angle()
	await get_tree().create_timer(life_time).timeout
	queue_free()


func _physics_process(delta):
	var motion = direction * speed * delta
	var collision = move_and_collide(motion)
	
	if collision:
		var collider = collision.get_collider()
		if collider and collider.is_in_group("enemy"):
			_apply_flame(collider)
		queue_free()


func _apply_flame(enemy: Node):
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)
		
		if enemy.is_in_group("flammable"):
			enemy.take_damage(extra_damage)
			if enemy.has_method("apply_slow") or enemy.has_method("set_slow"):
				# Варіант 1 — якщо у ворога є метод apply_slow(duration)
				if enemy.has_method("apply_slow"):
					enemy.apply_slow(randf_range(slow_duration_min, slow_duration_max))
				# Варіант 2 — якщо просто множник швидкості
				elif enemy.has_method("set_slow"):
					enemy.set_slow(0.0, randf_range(slow_duration_min, slow_duration_max))
