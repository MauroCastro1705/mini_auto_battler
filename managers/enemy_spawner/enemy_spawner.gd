extends Node


@onready var enemy_pool: EnemyPool = $"../EnemyPool"
@onready var spawner_area: Area2D = $spawner_area

@export var spawn_rate := 5.0

var enemies_spawned:int = 0
var enemies_to_spawn:int = 0

func _ready():
	Global.wave_advanced.connect(reset_wave_spawn)
	enemies_to_spawn = Global.get_enemies_per_wave()
	spawn_enemy_timer()

func spawn_enemy_timer():
	var timer = Timer.new()
	timer.wait_time = spawn_rate
	timer.autostart = true
	timer.timeout.connect(spawn_enemy)
	add_child(timer)

func spawn_enemy():
	if enemies_spawned >= enemies_to_spawn:
		return
	var spawn_pos = get_random_position_in_area()

	var enemy = enemy_pool.get_enemy()
	enemy.activate(spawn_pos)
	enemies_spawned += 1


func reset_wave_spawn():
	enemies_spawned = 0
	enemies_to_spawn = Global.get_enemies_per_wave()


func get_random_position_in_area() -> Vector2:
	var shape_node := spawner_area.get_node_or_null("CollisionShape2D")
	if not shape_node or not shape_node.shape:
		return spawner_area.global_position
	var rect_shape := shape_node.shape as RectangleShape2D
	var extents: Vector2 = rect_shape.extents

	# Random point in local space
	var local_pos := Vector2(
		randf_range(-extents.x, extents.x),
		randf_range(-extents.y, extents.y)
	)
	# Convert local point to global
	return spawner_area.global_position + local_pos
