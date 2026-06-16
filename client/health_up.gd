extends Area2D
@export var heal_points = int()
@export var dropped_from_enemy = true
@export var ground_check_distance := 50.0

var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta):
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2(0, ground_check_distance)
	)
	query.exclude = [self]
	query.collision_mask = 9

	var result = space_state.intersect_ray(query)
	
	if dropped_from_enemy:
		if result:
			velocity.y = 0
		else:
			velocity.y += gravity * delta  # Додаємо гравітацію
			position += velocity * delta   # Рухаємо об'єкт
		await get_tree().create_timer(15).timeout
		queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	pass # Replace with function body.

func _on_body_entered(body):	
	if body.name == "Player" and body.has_method("heal"):
		body.heal(heal_points)
		queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
