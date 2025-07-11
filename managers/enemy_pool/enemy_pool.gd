extends Node
class_name EnemyPool

@export var enemy_scene: PackedScene
@export var pool_size := 50

var pool: Array[Node] = []

func _ready():
	for i in pool_size:
		var enemy = enemy_scene.instantiate()
		enemy.hide()
		enemy.set_process(false)
		enemy.active = false # custom flag in Enemy.gd
		add_child(enemy)
		pool.append(enemy)

func get_enemy() -> Node:
	for enemy in pool:
		if is_instance_valid(enemy) and not enemy.active:
			return enemy
	# Expand pool if needed
	var enemy = enemy_scene.instantiate()
	enemy.hide()
	enemy.set_process(false)
	enemy.active = false
	add_child(enemy)
	pool.append(enemy)
	return enemy
