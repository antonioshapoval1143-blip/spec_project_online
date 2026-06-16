extends CharacterBody2D

@export var speed := 750.0
@export var life_time := 5.0
@export var damage := 20

var direction: Vector2 = Vector2.RIGHT
var owner_id: String = ""           # Додаємо
@export var is_owned_by_local_player := true

func _ready():
	OnlineMode.send_bullet_spawn(global_position, direction)
	
	await get_tree().create_timer(life_time).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta):
	var motion = direction * speed * delta
	var collision = move_and_collide(motion)
	
	if collision:
		var collider = collision.get_collider()
		
		if collider and is_owned_by_local_player:
			# Повідомляємо сервер про попадання
			if collider.has_method("get_player_id"):
				OnlineMode.send_bullet_hit(collider.get_player_id(), global_position)
		
		queue_free()
