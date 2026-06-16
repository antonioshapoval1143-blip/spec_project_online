extends CharacterBody2D
@export var bullet_scene: PackedScene

@export var max_health := 100
var current_health := max_health
@onready var health_fill = $HealthBar/HealthFill
@onready var health_bar = $HealthBar
@export var health_fill1: Control
@export var health_bar1: Control
@export var pause: Control
@export var score_frame: Control
@onready var sprite = $AnimatedSprite2D
var is_hurt := false
var can_shoot := true
var knockback_vector := Vector2.ZERO
var knockback_time := 0.3
var knockback_timer := 0.0
var is_in_enemy := false

var invincible := false  # Чи є гравець тимчасово недоторканним
var invincible_time := 1.5

signal health_changed(new_health)

#temp2

func _on_score_changed(new_score: int) -> void:
	score_frame.text = str(new_score)

#temp
func _input(event):
	if event.is_action_pressed("ui_cancel"):  # За замовчуванням ESC
		pause.visible = true
		get_tree().paused = !get_tree().paused
	if event.is_action_pressed("wep_menu"):
		if $CanvasLayer/InGameMenu.visible == false:
			$CanvasLayer/InGameMenu.visible = true
		else :
			$CanvasLayer/InGameMenu.visible = false
		#get_tree().paused = !get_tree().paused
		

func wep_menu():
	#var SW = $CanvasLayer/InGameMenu/SW
	var FW = $CanvasLayer/InGameMenu/FW
	var CW = $CanvasLayer/InGameMenu/CW
	var EW = $CanvasLayer/InGameMenu/EW
	if FileAccess.file_exists("user://current_prog"):
		var current_prog = FileAccess.open("user://current_prog", FileAccess.READ).get_var()
		if current_prog.M1 == 0:
			FW.visible = false
		if current_prog.M2 == 0:
			CW.visible = false
		if current_prog.M3 == 0:
			EW.visible = false
	else :
		FW.visible = false
		CW.visible = false
		EW.visible = false
		
			
func WM_func():
	var SW = $CanvasLayer/InGameMenu/SW
	var FW = $CanvasLayer/InGameMenu/FW
	var CW = $CanvasLayer/InGameMenu/CW
	var EW = $CanvasLayer/InGameMenu/EW
	if SW.button_pressed == true:
		change_bullet_scene(preload("res://projectile.tscn"))
		$CanvasLayer/InGameMenu.visible = false
	elif FW.button_pressed == true:
		change_bullet_scene(preload("res://heat_projectile.tscn"))
		$CanvasLayer/InGameMenu.visible = false
	elif CW.button_pressed == true:
		change_bullet_scene(preload("res://cryo_projectile.tscn"))
		$CanvasLayer/InGameMenu.visible = false
	elif EW.button_pressed == true:
		change_bullet_scene(preload("res://elec_projectile.tscn"))
		$CanvasLayer/InGameMenu.visible = false
	
	#get_tree().paused = !get_tree().paused
	

func change_bullet_scene(new_scene: PackedScene):
	if new_scene != null:
		bullet_scene = new_scene
		
	

func heal(amount: int):
	current_health += amount
	current_health = clamp(current_health, 0, max_health)

func take_damage(amount: int, from_direction: Vector2 = Vector2.ZERO):
	if invincible:
		return
		
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	emit_signal("health_changed", current_health)
	
	knockback_vector = Vector2(-from_direction.normalized().x * 300, 0)
	knockback_timer = knockback_time
	
	is_hurt = true
	can_shoot = false
	invincible = true
	$AnimatedSprite2D.play("get_hit")
	await flash()
	$AnimatedSprite2D.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	
	if current_health <= 0:
		die()
	else:
		is_hurt = false
		can_shoot = true
		await get_tree().create_timer(invincible_time, false).timeout
		invincible = false
		sprite.visible = true
		$AnimatedSprite2D.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func flash():
	var blink_count := 6
	for i in range(blink_count):
		sprite.visible = !sprite.visible
		await get_tree().create_timer(invincible_time / (blink_count * 2.0), false).timeout
	sprite.visible = true

func die():
	get_tree().change_scene_to_file("res://youre_dead.tscn")
	queue_free()

const SPEED = 300.0
@export var JUMP_VELOCITY = -800.0
const SHOOT_COOLDOWN = 0.3

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var shoot_timer = 0.0
var is_shooting = false  # Для відстеження стану стрільби

func _ready():
	wep_menu()
	#$CanvasLayer/InGameMenu/SW.visible = false
	Scores.start_scores()
	Scores.score_changed.connect(_on_score_changed)
	var your_score = int(FileAccess.open("user://temp_score", FileAccess.READ).get_var())
	#var cur_score = int(FileAccess.open("user://current_score", FileAccess.READ).get_var())
	#print(cur_score)
	#print(your_score)
	score_frame.text = str(your_score)
	
	#db_con()
	pause.visible = false
	$AnimatedSprite2D.play("idle")
	connect("health_changed", Callable(self, "update_health_bar"))  # Початкова анімація

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
	WM_func()
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
			$AnimatedSprite2D.flip_h = direction < 0  # Оновлення flip_h у будь-якому стані
			$Marker2D.position.x = abs($Marker2D.position.x) * (-1 if direction < 0 else 1)

		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Стрільба
	if Input.is_action_just_pressed("main_weapon") and shoot_timer <= 0:
		is_shooting = true
		shoot()
		shoot_timer = SHOOT_COOLDOWN
		# Запускаємо таймер для скидання is_shooting
		await get_tree().create_timer(SHOOT_COOLDOWN).timeout
		is_shooting = false

	update_animation(direction)
	move_and_slide()
#
var current_hp = int()
func _process(_delta):
	update_health_bar(current_health)
	
	if current_hp != current_health:
		print("Health:", current_health)
		current_hp = current_health
		
	#if is_in_enemy and not invincible:
		#take_damage(10, (global_position - enemy.global_position).normalized())
	#var Global = current_health
