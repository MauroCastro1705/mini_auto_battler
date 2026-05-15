extends Node


@onready var enemy_pool: EnemyPool = $"../EnemyPool"
@onready var spawner_area: Area2D = $spawner_area

# Randomized spawn interval (seconds)
@export var spawn_rate_min: float = 1.0
@export var spawn_rate_max: float = 5.0 # higher = slower

# How many enemies may spawn in one tick (default 1 for no bursts)
@export var spawn_max_per_tick: int = 1

var enemies_spawned: int = 0
var enemies_to_spawn: int = 0

var _spawn_timer: Timer = null

func _ready():
	Global.wave_advanced.connect(_on_wave_advanced)
	enemies_to_spawn = Global.get_enemies_per_wave()
	_ensure_spawn_timer()
	_schedule_next_spawn()

func _ensure_spawn_timer() -> void:
	# Reuse existing child timer if present to avoid duplicates
	if has_node("SpawnTimer"):
		_spawn_timer = $SpawnTimer
	else:
		_spawn_timer = Timer.new()
		_spawn_timer.name = "SpawnTimer"
		_spawn_timer.one_shot = true
		_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
		add_child(_spawn_timer)

func _schedule_next_spawn() -> void:
	if not _spawn_timer:
		_ensure_spawn_timer()
	# If we've already spawned the quota, stop until wave advances
	if enemies_spawned >= enemies_to_spawn:
		_spawn_timer.stop()
		return
	var wait = randf_range(spawn_rate_min, spawn_rate_max)
	_spawn_timer.wait_time = wait
	_spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	_spawn_enemies_tick()
	# Schedule next only if still need to spawn
	if enemies_spawned < enemies_to_spawn:
		_schedule_next_spawn()

func _spawn_enemies_tick() -> void:
	if enemies_spawned >= enemies_to_spawn:
		return
	# determine how many to spawn this tick, clamp to remaining
	var remaining = enemies_to_spawn - enemies_spawned
	var max_spawn = min(spawn_max_per_tick, remaining)
	var to_spawn = 1
	if max_spawn > 1:
		to_spawn = randi_range(1, max_spawn)

	for i in range(to_spawn):
		var spawn_pos = get_random_position_in_area()
		var enemy = enemy_pool.get_enemy()
		# defensive: ensure enemy is valid and not active
		if is_instance_valid(enemy) and not enemy.active:
			enemy.activate(spawn_pos)
			enemies_spawned += 1
		else:
			# skip and continue; avoid blocking other spawns
			continue


func _on_wave_advanced() -> void:
	enemies_spawned = 0
	enemies_to_spawn = Global.get_enemies_per_wave()
	# small randomized delay before next wave spawns to avoid bursts
	if _spawn_timer:
		_spawn_timer.stop()
	_schedule_next_spawn()


func get_random_position_in_area() -> Vector2:
	var shape_node := spawner_area.get_node_or_null("CollisionShape2D")
	if not shape_node or not shape_node.shape:
		return spawner_area.global_position
	var shape = shape_node.shape

	# RectangleShape2D: uniform point inside rect
	if shape is RectangleShape2D:
		var rect_shape := shape as RectangleShape2D
		var extents: Vector2 = rect_shape.extents
		var local_pos := Vector2(
			randf_range(-extents.x, extents.x),
			randf_range(-extents.y, extents.y)
		)
		return shape_node.to_global(local_pos)

	# CircleShape2D: uniform point inside circle
	if shape is CircleShape2D:
		var circle := shape as CircleShape2D
		var r = sqrt(randf()) * circle.radius
		var a = randf() * TAU
		var local_pos = Vector2(cos(a), sin(a)) * r
		return shape_node.to_global(local_pos)

	# CapsuleShape2D fallback: approximate by rect extents + circle ends
	if shape is CapsuleShape2D:
		var cap := shape as CapsuleShape2D
		var radius = cap.radius
		var height = cap.height
		# sample along capsule axis
		var t = randf_range(-height * 0.5, height * 0.5)
		var a = randf() * TAU
		var local_pos = Vector2(cos(a), sin(a)) * (sqrt(randf()) * radius)
		local_pos.x += t
		return shape_node.to_global(local_pos)

	# Other shapes: try to use a bounding box around the shape_node
	var aabb = shape.get_aabb() if shape.has_method("get_aabb") else Rect2(-64, -64, 128, 128)
	var lx = randf_range(aabb.position.x, aabb.position.x + aabb.size.x)
	var ly = randf_range(aabb.position.y, aabb.position.y + aabb.size.y)
	return shape_node.to_global(Vector2(lx, ly))
