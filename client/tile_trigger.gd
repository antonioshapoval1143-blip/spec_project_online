extends Node

@export var tilemap_layer: TileMapLayer
@export var player_group: String = "player"              # група, в якій гравець
@export var custom_data_layer_name: String = "on_stand"  # назва твого Custom Data Layer
@export var position_offset: Vector2 = Vector2(0, 8)

var previous_tile_pos := Vector2i(-10000, -10000)
var player: Node = null

func _ready() -> void:
	if not tilemap_layer:
		print("TileMapLayer не призначено в TileEffectHandler")
		return

	# Знаходимо гравця один раз
	var players = get_tree().get_nodes_in_group(player_group)
	if players.size() > 0:
		player = players[0]
	else:
		print("Гравець з групою '" + player_group + "' не знайдений")

func _physics_process(_delta: float) -> void:
	if not player or not tilemap_layer:
		return
	
	var check_pos = player.global_position + position_offset
	var tile_pos = tilemap_layer.local_to_map(tilemap_layer.to_local(check_pos))
	
	if tile_pos == previous_tile_pos:
		return
	
	previous_tile_pos = tile_pos
	
	var tile_data: TileData = tilemap_layer.get_cell_tile_data(tile_pos)
	
	if tile_data:
		var action = tile_data.get_custom_data(custom_data_layer_name)
		if action is String and action != "":
			_execute_action(action)

func _execute_action(action: String) -> void:
	if not player:
		return

	# Варіант 1 — якщо ти готовий називати методи в гравцеві як "heal_20", "damage_15" тощо
	if player.has_method(action):
		player.call_deferred(action)
		return

#func handle_tile_trigger(tile_data: TileData, player: Node):
	#if not tile_data:
		#return
	#
	#var func_name = tile_data.get_custom_data("damage_function")
	#if func_name == "die":
		#player.die()
