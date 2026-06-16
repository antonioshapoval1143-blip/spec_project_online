extends CharacterBody2D
@export var bullet_scene: PackedScene

var is_local_player := true
@export var max_health := 100
var current_health := max_health
@onready var health_fill = $HealthBar/HealthFill
@onready var health_bar = $HealthBar
@export var health_fill1: Control
@export var health_bar1: Control
@export var pause: Control
@export var notification: Control
#@export var score_frame: Control
@export var nickname: Label
@onready var sprite = $AnimatedSprite2D
var is_hurt := false
var can_shoot := true
var knockback_vector := Vector2.ZERO
var knockback_time := 0.3
var knockback_timer := 0.0
var is_in_enemy := false

var is_dead := false

var invincible := false  # Чи є гравець тимчасово недоторканним
var invincible_time := 1.5

signal health_changed(new_health)

	
func get_player_id() -> String:
	return OnlineMode.my_player_id

#temp
func _input(event):
	if event.is_action_pressed("ui_cancel"):  # За замовчуванням ESC
		pause.visible = true


#func take_damage(amount: int, from_direction: Vector2 = Vector2.ZERO):
	#if invincible:
		#return
		#
	#current_health -= amount
	#current_health = clamp(current_health, 0, max_health)
	#emit_signal("health_changed", current_health)
	#
	#knockback_vector = Vector2(-from_direction.normalized().x * 300, 0)
	#knockback_timer = knockback_time
	#
	#is_hurt = true
	#can_shoot = false
	#invincible = true
	#$AnimatedSprite2D.play("get_hit")
	#await flash()
	#$AnimatedSprite2D.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	#
	#if current_health <= 0:
		##die()
		#pass
	#else:
		#is_hurt = false
		#can_shoot = true
		#await get_tree().create_timer(invincible_time, false).timeout
		#invincible = false
		#sprite.visible = true
		#$AnimatedSprite2D.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
#
#func flash():
	#var blink_count := 6
	#for i in range(blink_count):
		#sprite.visible = !sprite.visible
		#await get_tree().create_timer(invincible_time / (blink_count * 2.0), false).timeout
	#sprite.visible = true


const SPEED = 300.0
@export var JUMP_VELOCITY = -800.0
const SHOOT_COOLDOWN = 0.3

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var shoot_timer = 0.0
var is_shooting = false  # Для відстеження стану стрільби

func _ready():
	nickname.text = str(FileAccess.open("user://login", FileAccess.READ).get_var().nickname)
	OnlineMode.player_died.connect(_on_player_died)
	
	OnlineMode.hp_updated.connect(_on_hp_updated)
	OnlineMode.player_left.connect(_on_other_left)
	
	if is_local_player:
		OnlineMode.game_state_updated.connect(_on_other_player_updated)
	$CanvasLayer3/MP_Pause.visible = false
	$AnimatedSprite2D.play("idle")
	connect("health_changed", Callable(self, "update_health_bar"))

func _on_other_left(player_id):
	if is_dead != true:
		print(player_id+" left you alone")
		notification.visible = true
		get_tree().paused = !get_tree().paused

func _on_player_died(player_id):
	is_dead = true
	print("dead player id: " + player_id)
	var your_id = get_player_id()
	print("you are " + your_id)
	var your_pr_id = int(FileAccess.open("user://login", FileAccess.READ).get_var().player_id)
	var other = FileAccess.open("user://rpl_data.txt", FileAccess.READ).get_var()
	var other_pr_id = int(other.profile_id)
	var mp_status = FileAccess.open("user://mp_lobby_status", FileAccess.READ).get_as_text()
	if player_id != your_id:
		FileAccess.open("user://winner", FileAccess.WRITE).store_string(nickname.text)
		if mp_status == "cr":
			await DbConnection.mp_result(your_pr_id, other_pr_id, your_pr_id)
		else:
			await DbConnection.mp_result(other_pr_id, your_pr_id, your_pr_id)
	else:
		FileAccess.open("user://winner", FileAccess.WRITE).store_string(other.others_nick)
	OnlineMode.disconnect_player()
	get_tree().change_scene_to_file("res://mp_finish.tscn")
	queue_free()

func _on_hp_updated(player_id: String, hp: int):

	if player_id != OnlineMode.my_player_id:
		return

	current_health = hp

	update_health_bar(current_health)

	print("NEW HP: ", hp)

func update_health_bar(new_health: int):
	var ratio := float(new_health) / max_health
	health_fill.size.y = health_bar.size.y * ratio
	health_fill1.size.y = health_bar1.size.y * ratio

func shoot():
	if bullet_scene == null:
		print("Bullet scene not assigned!")
		return
	
	if not can_shoot or bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = $Marker2D.global_position

	# Напрямок кулі
	if $AnimatedSprite2D.flip_h:
		bullet.direction = Vector2.LEFT
		bullet.rotation_degrees = 180
	else:
		bullet.direction = Vector2.RIGHT

func update_animation(direction):
	
	if is_hurt:
		return
	
	# Якщо персонаж стріляє і стоїть на землі
	if is_shooting and is_on_floor():
		if direction != 0:
			$AnimatedSprite2D.play("shoot_run")
		else:
			$AnimatedSprite2D.play("shoot")
	# Якщо персонаж у повітрі
	elif not is_on_floor():
		$AnimatedSprite2D.play("jump")
	# Якщо персонаж на землі і рухається
	elif direction != 0:
		$AnimatedSprite2D.play("run")
	# Якщо персонаж на землі і стоїть
	else:
		$AnimatedSprite2D.play("idle")

func _physics_process(delta):
	#WM_func()
	shoot_timer -= delta
	
	var direction = 0.0

	if knockback_timer > 0:
		knockback_timer -= delta
		velocity.x = knockback_vector.x  # тільки X
		velocity.y += gravity * delta    # падіння вниз дозволено
		return
	else:
		# Гравітація
		if not is_on_floor():
			velocity.y += gravity * delta

		# Стрибок
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Рух
		if not is_hurt:
			direction = Input.get_axis("ui_left", "ui_right")
		
		if direction:
			velocity.x = direction * SPEED
			$AnimatedSprite2D.flip_h = direction < 0
			$Marker2D.position.x = abs($Marker2D.position.x) * (-1 if direction < 0 else 1)

		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Стрільба
	if Input.is_action_just_pressed("main_weapon") and shoot_timer <= 0:
		is_shooting = true
		shoot()
		shoot_timer = SHOOT_COOLDOWN
		await get_tree().create_timer(SHOOT_COOLDOWN).timeout
		is_shooting = false
		shoot_timer = 0.3
		
	if OnlineMode.connected:
		OnlineMode.send_position(
			global_position,
			velocity,
			sprite.animation,
			sprite.flip_h,
			Input.is_action_pressed("main_weapon")
		)

	update_animation(direction)
	move_and_slide()
#
var current_hp = int()
func _process(_delta):
	update_health_bar(current_health)
	
	if current_hp != current_health:
		print("Health:", current_health)
		current_hp = current_health
		
	
func _on_other_player_updated(data: Dictionary):
	pass
