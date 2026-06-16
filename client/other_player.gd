extends CharacterBody2D

const INTERPOLATION_SPEED := 12.0

var target_position := Vector2.ZERO

@export var mirror_mode := true
@export var arena_center_x := 0.0
@export var bullet_scene: PackedScene
@export var health_bar: Control
@export var health_fill: Control
@export var max_health := 100
var current_health := 100
var player_id := ""
var side
var current_player_data = FileAccess.open("user://rpl_data.txt", FileAccess.READ).get_var()
var nickname = str(current_player_data.others_nick)

@onready var sprite = $AnimatedSprite2D

func get_player_id() -> String:
	return player_id

	
func _on_bullet_spawned(data: Dictionary):
	#print(str(data["player_id"]))
	#print(player_id)

	if str(data["player_id"]) != player_id:
		print("nope")
		return
	#if player_id == OnlineMode.my_player_id:
		#return

	var bullet = bullet_scene.instantiate()

	get_parent().add_child(bullet)

	bullet.global_position = $Marker2D.global_position

	var dirx = data["dir_x"]
	if side == 1:
		bullet.direction = Vector2(
			dirx,
			data["dir_y"]
		)
	else:
		bullet.direction = Vector2(
			dirx*-1,
			data["dir_y"]
		)
		
	

	#bullet.is_owned_by_local_player = false
	
func _on_hp_updated_remote(player_id: String, hp: int):
	# Оновлюємо, якщо це HP іншого гравця (тобто наш remote)
	if player_id != OnlineMode.my_player_id:
		current_health = hp
		update_health_bar()

func update_health_bar():
	if not health_fill or not health_bar:
		return
	var ratio = clamp(float(current_health) / max_health, 0, 1)
	health_fill.size.y = health_bar.size.y * ratio

func _ready():
	$Label.text = nickname

	OnlineMode.game_state_updated.connect(
		_on_game_state_updated
	)
	OnlineMode.bullet_spawned.connect(_on_bullet_spawned)
	#OnlineMode.remote_shot.connect(
		#_on_remote_shot
	#)
	OnlineMode.hp_updated.connect(_on_hp_updated_remote)
	

func _on_remote_shot(data: Dictionary):

	var bullet = bullet_scene.instantiate()

	get_parent().add_child(bullet)

	bullet.global_position = Vector2(
		data["x"],
		data["y"]
	)

	bullet.direction = Vector2(
		data["dir_x"],
		data["dir_y"]
	)

func _process(delta):

	global_position = global_position.lerp(
		target_position,
		INTERPOLATION_SPEED * delta
	)

func _on_game_state_updated(data: Dictionary):

	var pos_x = data["x"]
	var vel_x = data["vx"]
	var flip = data["flip_h"]
	player_id = str(data["player_id"])

	# ─────────────────────────
	# MIRROR
	# ─────────────────────────
	if mirror_mode:
		pos_x = arena_center_x - (
			pos_x - arena_center_x
		)
		vel_x = -vel_x
		flip = !flip

	target_position = Vector2(
		pos_x,
		data["y"]
	)

	sprite.flip_h = flip
	if flip:
		$Marker2D.position.x = -abs($Marker2D.position.x)
		side = -1
		
	else:
		$Marker2D.position.x = abs($Marker2D.position.x)
		side = 1

	var anim = str(data["anim"])

	if sprite.animation != anim:
		sprite.play(anim)

#const INTERPOLATION_SPEED := 12.0
#
#var target_position := Vector2.ZERO
#
#@onready var sprite = $AnimatedSprite2D
#
#func _ready():
#
	#OnlineMode.game_state_updated.connect(
		#_on_game_state_updated
	#)
#
#func _process(delta):
#
	#global_position = global_position.lerp(
		#target_position,
		#INTERPOLATION_SPEED * delta
	#)
#
#func _on_game_state_updated(data: Dictionary):
#
	#target_position = Vector2(
		#data["x"],
		#data["y"]
	#)
#
	#sprite.flip_h = data["flip_h"]
#
	#var anim = str(data["anim"])
#
	#if sprite.animation != anim:
		#sprite.play(anim)
