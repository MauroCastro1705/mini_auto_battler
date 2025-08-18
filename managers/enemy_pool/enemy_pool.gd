extends Node
class_name EnemyPool

@export var enemy_scene: PackedScene
@export var pool_size := 50

var pool: Array[Node] = []


func _ready():
	for i in pool_size:
		var enemy = enemy_scene.instantiate()
		add_child(enemy)  # IMPORTANTE: permite que enemy._ready() cachee capas reales
		enemy.active = false
		enemy.is_dead = true
		enemy.hide()
		enemy.set_process(false)
		enemy.set_physics_process(false)
		pool.append(enemy)

func get_enemy() -> Node:
	for enemy in pool:
		if is_instance_valid(enemy) and not enemy.active:
			return enemy
	var enemy = enemy_scene.instantiate()
	add_child(enemy)  # igual que arriba: primero al árbol
	enemy.active = false
	enemy.is_dead = true
	enemy.hide()
	enemy.set_process(false)
	enemy.set_physics_process(false)
	pool.append(enemy)
	return enemy
