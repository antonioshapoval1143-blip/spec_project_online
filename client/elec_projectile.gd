extends CharacterBody2D

@export var speed := 850.0          # трохи швидший за звичайний
@export var life_time := 4.5
@export var damage := 5
@export var dot_damage := 2         # damage over time
@export var dot_duration := 2.0
@export var dot_ticks := 4          # скільки разів нанесе dot_damage

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
			_apply_electric(collider)
		queue_free()


func _apply_electric(enemy: Node):
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)
		
		if enemy.is_in_group("electric"):
			# Додаємо невеликий DoT (шкода з часом)
			if enemy.has_method("apply_dot"):
				enemy.apply_dot(dot_damage, dot_duration, dot_ticks)
			else:
				# простий fallback — одразу нанести частину шкоди
				var total_dot = dot_damage * dot_ticks
				enemy.take_damage(total_dot / 2)   # половина, щоб не було занадто сильно
