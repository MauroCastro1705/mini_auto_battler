extends Node


@onready var enemy_pool: EnemyPool = $"../EnemyPool"

@export var spawn_rate := 5.0
@export var spawn_radius := 500.0


func _ready():
	var timer = Timer.new()
	timer.wait_time = spawn_rate
	timer.autostart = true
	timer.timeout.connect(spawn_enemy)
	add_child(timer)

func spawn_enemy():
	var player_pos = Global.player.global_position
	var angle = randf() * TAU
	var spawn_pos = player_pos + Vector2.RIGHT.rotated(angle) * spawn_radius

	var enemy = enemy_pool.get_enemy()
	enemy.activate(spawn_pos)
