extends CharacterBody2D

@export var point_a: Node2D
@export var point_b: Node2D
@export var speed: float = 100.0
@export var max_health := 20
@export var damage := 10
@export var damage_cooldown := 0.5
@export var bullet_scene: PackedScene
@export var item1_scene: PackedScene
@export var item2_scene: PackedScene
@export var item3_scene: PackedScene

var current_health := max_health
signal health_changed(new_health)

var target_position: Vector2
var moving_to_b: bool = true

var player: Node = null
var player_in_zone := false
var cooldown_timer := 0.0
var dead = false

func _ready():
	$AnimatedSprite2D.play("default")

	if point_a and point_b:
		target_position = point_b.global_position
	else:
		push_error("Точки A або B не встановлені!")

	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)
	
	$AnimatedSprite2D.play("default")

	$view.body_entered.connect(_on_view_entered)
	$view.body_exited.connect(_on_view_exited)


func shoot():
	if bullet_scene == null:
		print("Bullet scene not assigned!")
		return

	# Кути у градусах ВІДНОСНО ВОРОГА
	var angles = [-45, 0, 45]  # Вліво, прямо, вправо

	# Вибираємо набір маркерів залежно від напрямку спрайту
	var markers
	if $AnimatedSprite2D.flip_h:  # Дивиться вправо
		markers = [$Node2D2/Marker2D, $Node2D2/Marker2D3, $Node2D2/Marker2D2]
	else:  # Дивиться вліво
		markers = [$Node2D/Marker2D, $Node2D/Marker2D3, $Node2D/Marker2D2]

	# Якщо дивиться вліво, інвертувати кути
	if not $AnimatedSprite2D.flip_h:
		for i in range(len(angles)):
			angles[i] = 180 - angles[i]

	for i in range(3):
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.global_position = markers[i].global_position
		
		var angle_rad = deg_to_rad(angles[i])
		bullet.direction = Vector2(cos(angle_rad), sin(angle_rad)).normalized()
		bullet.rotation = angle_rad

func _on_view_entered(body):
	if body.name == "Player":
		player = body
		$AnimatedSprite2D.flip_h = player.global_position.x > global_position.x
		print("Facing player (from view), flip_h: ", $AnimatedSprite2D.flip_h)

func _on_view_exited(body):
	if body.name == "Player":
		player = null  # або залишити, якщо треба продовжити стріляти


func take_damage(amount: int):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	emit_signal("health_changed", current_health)

	if current_health <= 0:
		dead = true
		$AnimatedSprite2D.play("death")
		await $AnimatedSprite2D.animation_finished
		Scores.add_score(20)
		spawn_random_item()
		queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		player = body
		player_in_zone = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_zone = false
		player = null

func _physics_process(delta):
	# Рух
	if dead == false:
		if point_a and point_b:
			var direction = (target_position - global_position).normalized()
			velocity = direction * speed
			move_and_slide()

			if global_position.distance_to(target_position) < 5.0:
				face_player()
				shoot()
				#await get_tree().create_timer(2.5).timeout
				moving_to_b = !moving_to_b
				target_position = point_b.global_position if moving_to_b else point_a.global_position

		# Завдавання шкоди
		if cooldown_timer > 0:
			cooldown_timer -= delta

		if player_in_zone and cooldown_timer <= 0 and player and player.has_method("take_damage"):
			player.take_damage(damage, global_position.direction_to(player.global_position))
			cooldown_timer = damage_cooldown
			
func spawn_random_item():
	var rand = randf()  # Випадкове число від 0 до 1

	if rand < 0.3:  # 30% шанс
		spawn_item(item1_scene)
	elif rand < 0.5:  # +20% = 50%
		spawn_item(item2_scene)
	elif rand < 0.6:  # +10% = 60%
		spawn_item(item3_scene)
	else:
		pass

func face_player():
	if is_instance_valid(player):
		$AnimatedSprite2D.flip_h = player.global_position.x > global_position.x
		print("Facing player, flip_h: ", $AnimatedSprite2D.flip_h)  # Дебаг-вивід
	else:
		print("No valid player to face!")
	
func spawn_item(scene: PackedScene):
	if scene:
		var item_instance = scene.instantiate()
		get_tree().current_scene.add_child(item_instance)
		item_instance.global_position = global_position



func apply_slow(multiplier: float, duration: float):
	var original_speed = speed
	speed *= multiplier
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(self):
		speed = original_speed


func apply_freeze(duration: float):
	var was_moving = velocity.length() > 0
	velocity = Vector2.ZERO
	# можна ще змінити колір на синій / додати частинки
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(self) and was_moving:
		pass


func apply_dot(damage_per_tick: float, total_time: float, tick_count: int):
	var tick_interval = total_time / tick_count
	for i in tick_count:
		if not is_instance_valid(self): return
		take_damage(int(damage_per_tick))
		await get_tree().create_timer(tick_interval).timeout
