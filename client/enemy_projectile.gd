extends CharacterBody2D

@export var speed := 750.0
@export var life_time := 5.0
var direction: Vector2 = Vector2.RIGHT

func _ready():
	# Автоматичне знищення кулі через life_time секунд
	await get_tree().create_timer(life_time).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta):
	#position += direction * speed * delta
	var motion = direction.normalized() * speed * delta
	var collision = move_and_collide(motion)
	
	if collision:
		var obj = collision.get_collider()
		if obj and obj.name == "Player" and obj.has_method("take_damage"):
			obj.take_damage(5)
		queue_free()
