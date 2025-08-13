extends Node


@onready var enemy_pool: EnemyPool = $"../EnemyPool"

@export var spawn_rate := 5.0
@export var spawn_radius := 500.0
var enemies_spawned:int = 0
var enemies_to_spawn:int = 0

func _ready():
	Global.wave_advanced.connect(reset_wave_spawn)
	enemies_to_spawn = Global.get_enemies_per_wave()
	var timer = Timer.new()
	timer.wait_time = spawn_rate
	timer.autostart = true
	timer.timeout.connect(spawn_enemy)
	add_child(timer)


func spawn_enemy():
	if enemies_spawned >= enemies_to_spawn:
		return # Dont spawn more than needed

	var player_pos = Global.player.global_position
	var angle = randf() * TAU
	var spawn_pos = player_pos + Vector2.RIGHT.rotated(angle) * spawn_radius

	var enemy = enemy_pool.get_enemy()
	enemy.activate(spawn_pos)

	enemies_spawned += 1

func reset_wave_spawn():
	enemies_spawned = 0
	enemies_to_spawn = Global.get_enemies_per_wave()
