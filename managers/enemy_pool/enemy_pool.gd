extends Node
class_name EnemyPool


@export var enemy_scene: PackedScene## Single-scene fallback for compatibility

@export var enemy_scenes: Array[PackedScene] = []## New: allow configuring multiple enemy scenes

@export var pool_size := 50## Pool size (total number of pre-instantiated enemies)

@export var spawn_intervals: Array[float] = []## intervalo de spawn segun enemigo  ( in seconds). 

@export var spawn_rarities: Array[float] = []## rareza segun enemigos (higher = more likely)

var pool: Array[Node] = []

func _ready():
	randomize()
	for i in range(pool_size):
		var idx = _select_scene_index()
		var scene: PackedScene = _get_scene_by_index(idx)
		var enemy = scene.instantiate()
		add_child(enemy)  # IMPORTANTE: permite que enemy._ready() cachee capas reales
		enemy.set_meta("enemy_type", idx)
		enemy.active = false
		enemy.is_dead = true
		enemy.hide()
		enemy.set_process(false)
		enemy.set_physics_process(false)
		pool.append(enemy)

func _get_scene_by_index(idx: int) -> PackedScene:
	if enemy_scenes.size() > 0:
		if idx >= 0 and idx < enemy_scenes.size():
			return enemy_scenes[idx]
		# fallback to first if out-of-range
		return enemy_scenes[0]

	# fallback to single exported scene for compatibility
	if enemy_scene:
		return enemy_scene

	push_error("No enemy scene(s) assigned to EnemyPool")
	return PackedScene.new()

func _select_scene_index() -> int:
	var count = enemy_scenes.size()
	# If no multi-scenes provided, treat fallback single scene as index 0
	if count == 0:
		return 0

	# If rarities provided and match count, use weighted random
	if spawn_rarities.size() == count:
		var total := 0.0
		for r in spawn_rarities:
			total += float(r)
		if total <= 0.0:
			return randi() % count
		var pick := randf() * total
		var cum := 0.0
		for i in range(count):
			cum += float(spawn_rarities[i])
			if pick <= cum:
				return i
		return count - 1

	# Otherwise, uniform random
	return randi() % count

func get_enemy(type_index: int = -1) -> Node:
	# Try to find an inactive enemy in the pool (optionally matching a type)
	for enemy in pool:
		if is_instance_valid(enemy) and not enemy.active and enemy.is_dead:
			if type_index == -1:
				return enemy
			var meta = enemy.get_meta("enemy_type")
			if meta == type_index:
				return enemy

	# None available: instantiate new one of requested (or random) type
	var idx = type_index
	if idx == -1:
		idx = _select_scene_index()

	var scene = _get_scene_by_index(idx)
	var enemy = scene.instantiate()
	add_child(enemy)  # igual que arriba: primero al árbol
	enemy.set_meta("enemy_type", idx)
	enemy.active = false
	enemy.is_dead = true
	enemy.hide()
	enemy.set_process(false)
	enemy.set_physics_process(false)
	pool.append(enemy)
	return enemy
