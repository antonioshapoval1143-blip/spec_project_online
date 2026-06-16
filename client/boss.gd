extends CharacterBody2D

enum State { IDLE, SHOOT, BOMBARD }
var current_state = State.IDLE
var initial_position: Vector2
var is_attacking = false  # Чи виконується атака
var is_bombarding = false  # Чи активне бомбардування
@export var is_enabled: bool = true  # Чи активний ворог

@export var projectile_scene: PackedScene
@export var warning_scene: PackedScene  # Сцена попередження
@export var explosion_scene: PackedScene  # Сцена вибуху
@export var area_node: Area2D  # Зона для бомбардування
@export var projectile_damage: int = 10
@export var explosion_damage: int = 15
@export var max_health: int = 200
@export var bombard_count: int = 3  # Кількість вибухів за атаку
@export var warning_duration: float = 1.0  # Тривалість попередження
@export var damage: int = 10  # Шкода від хітбоксів
@export var damage_cooldown: float = 0.5  # Час між ударами
@export var min_explosion_spacing: float = 40  # Мінімальна відстань між вибухами
@onready var hitbox_player1: Area2D = $Area2D2
@onready var hitbox_player2: Area2D = $Area2D3
@onready var platform_collider = $CollisionPolygon2D
@onready var damage_receiver: Area2D = $Area2D4
@onready var projectile_marker: Marker2D = $Marker2D
@export var health_fill: Control
@export var health_bar: Control
@export var finish: Control

var current_health: int
var shoot_timer = 0.0
var player: Node2D
var rng = RandomNumberGenerator.new()
var active_projectiles = []  # Відстеження активних снарядів
var active_explosions = []  # Відстеження активних вибухів
var knockback_vector: Vector2 = Vector2.ZERO
var knockback_time: float = 0.3
var knockback_timer: float = 0.0
var player_in_hitbox1: bool = false
var player_in_hitbox2: bool = false
var cooldown_timer: float = 0.0

signal health_changed(new_health)

func _ready():
	$AnimatedSprite2D.play("default")
	rng.randomize()
	initial_position = global_position
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")
	if area_node == null:
		area_node = $Area2D
	if health_bar and health_fill:
		update_health_bar(current_health)
	else:
		push_warning("HealthBar or HealthFill not found!")
	connect("health_changed", Callable(self, "update_health_bar"))
	
	# Підключення сигналів для хітбоксів
	hitbox_player1.body_entered.connect(_on_hitbox1_entered)
	hitbox_player1.body_exited.connect(_on_hitbox1_exited)
	hitbox_player2.body_entered.connect(_on_hitbox2_entered)
	hitbox_player2.body_exited.connect(_on_hitbox2_exited)
	
	# Підключення сигналу для отримання шкоди через Area2D4
	damage_receiver.body_entered.connect(_on_damage_receiver_entered)

func _physics_process(delta):
	if not is_enabled:
		return
	
	if knockback_timer > 0:
		knockback_timer -= delta
		velocity = knockback_vector
		move_and_slide()
		_update_collision_positions()
		return
	
	# Обробка шкоди від хітбоксів
	if cooldown_timer > 0:
		cooldown_timer -= delta
	if (player_in_hitbox1 or player_in_hitbox2) and cooldown_timer <= 0 and player and player.has_method("take_damage"):
		player.take_damage(damage, global_position.direction_to(player.global_position))
		cooldown_timer = damage_cooldown
	
	# Обробка станів
	match current_state:
		State.IDLE:
			_handle_idle_state()
		State.SHOOT:
			_handle_shoot_state()
		State.BOMBARD:
			_handle_bombard_state()

func _update_collision_positions():
	hitbox_player1.global_position = global_position
	hitbox_player2.global_position = global_position
	platform_collider.global_position = global_position
	damage_receiver.global_position = global_position

func _handle_idle_state():
	if is_attacking or is_bombarding:
		return
	
	var rand = rng.randf()
	if rand < 0.6 and not is_bombarding:
		current_state = State.SHOOT
	else:
		current_state = State.BOMBARD

func _handle_shoot_state():
	if is_attacking or is_bombarding:
		return
	
	is_attacking = true
	if player and projectile_marker:
		var projectile = projectile_scene.instantiate()
		projectile.global_position = projectile_marker.global_position
		projectile.target = player
		projectile.damage = projectile_damage
		projectile.connect("tree_exited", Callable(self, "_on_projectile_finished"))
		get_tree().current_scene.add_child(projectile)
		active_projectiles.append(projectile)
	current_state = State.IDLE

func _handle_bombard_state():
	
	
	
	if is_attacking:
		return
	
	is_attacking = true
	is_bombarding = true
	var area_shape = area_node.get_node("CollisionShape2D").shape as RectangleShape2D
	var area_size = area_shape.extents * 2
	var used_positions = []  # Список для відстеження використаних позицій
	
	for i in range(bombard_count):
		var random_pos
		var attempts = 0
		const MAX_ATTEMPTS = 10
		
		# Спроба знайти позицію, яка не надто близько до попередніх
		while attempts < MAX_ATTEMPTS:
			random_pos = Vector2(
				rng.randf_range(-area_size.x, area_size.x + 10),
				rng.randf_range(-area_size.y, -area_size.y)
			) + area_node.global_position
			
			var too_close = false
			for pos in used_positions:
				if random_pos.distance_to(pos) < min_explosion_spacing:
					too_close = true
					break
			if not too_close:
				break
			attempts += 1
		
		used_positions.append(random_pos)
		
		var warning = warning_scene.instantiate()
		warning.global_position = random_pos
		warning.connect("warning_finished", Callable(self, "_spawn_explosion").bind(random_pos))
		get_tree().current_scene.add_child(warning)
	
	await get_tree().create_timer(warning_duration + 0.5).timeout
	is_attacking = false
	current_state = State.IDLE

func _spawn_explosion(pos: Vector2):
	var explosion = explosion_scene.instantiate()
	explosion.global_position = pos
	explosion.damage = explosion_damage
	explosion.connect("tree_exited", Callable(self, "_on_explosion_finished"))
	get_tree().current_scene.add_child(explosion)
	active_explosions.append(explosion)

func _on_projectile_finished():
	if active_projectiles.size() > 0:
		active_projectiles.erase(active_projectiles[0])
	if active_projectiles.is_empty():
		is_attacking = false

func _on_explosion_finished():
	if active_explosions.size() > 0:
		active_explosions.erase(active_explosions[0])
	if active_explosions.is_empty():
		is_bombarding = false
		is_attacking = false

func _on_hitbox1_entered(body):
	if body.name == "Player":
		player_in_hitbox1 = true

func _on_hitbox1_exited(body):
	if body.name == "Player":
		player_in_hitbox1 = false

func _on_hitbox2_entered(body):
	if body.name == "Player":
		player_in_hitbox2 = true

func _on_hitbox2_exited(body):
	if body.name == "Player":
		player_in_hitbox2 = false

func _on_damage_receiver_entered(body):
	if body.has_method("get_damage") and body.is_in_group("player_projectile"):
		if body.is_in_group("shield"):
			return  # Шкода не наноситься, якщо снаряд належить до групи "shield"
		var damage_amount = body.get_damage()
		var direction = global_position.direction_to(body.global_position)
		take_damage(damage_amount, direction)

func take_damage(amount: int, from_direction: Vector2 = Vector2.ZERO):
	if not is_enabled:
		return
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	emit_signal("health_changed", current_health)
	
	knockback_vector = from_direction.normalized() * 300
	knockback_timer = knockback_time
	
	if current_health <= 0:
		die()

func update_health_bar(new_health: int):
	if health_bar and health_fill:
		var ratio := float(new_health) / max_health
		health_fill.size.y = health_bar.size.y * ratio

func die():
	Scores.add_score(100)
	var file = FileAccess.open("user://temp_score", FileAccess.READ)
	var scores = file.get_var()
	Scores.end_save(scores)
	var current_prog = {
		"M1": 0,
		"M2": 0,
		"M3": 0,
		"M4": 0
	}
	FileAccess.open("user://current_prog", FileAccess.WRITE).store_var(current_prog)
	#get_tree().change_scene_to_file("res://you_win.tscn")
	finish.visible = true
	get_tree().paused = !get_tree().paused
	queue_free()

func set_enabled(enabled: bool):
	is_enabled = enabled
	if not is_enabled:
		$AnimatedSprite2D.stop()
	else:
		$AnimatedSprite2D.play("default")
