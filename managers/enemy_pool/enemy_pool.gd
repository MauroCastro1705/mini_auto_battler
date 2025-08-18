extends Node
class_name EnemyPool

@export var enemy_scene: PackedScene
@export var pool_size := 50

var pool: Array[Node] = []

func _ready():
	for i in pool_size:
		var enemy = enemy_scene.instantiate()
		# Estado “muerto/inactivo” por defecto
		enemy.active = false
		enemy.is_dead = true
		enemy.hide()
		# Detén ambos tipos de proceso al entrar al pool
		enemy.set_process(false)
		enemy.set_physics_process(false)
		# Si tiene helpers, desactiva colisiones (si no, ignora silenciosamente)
		if enemy.has_method("_disable_collisions_now"):
			enemy._disable_collisions_now()
		add_child(enemy)
		pool.append(enemy)

func get_enemy() -> Node:
	for enemy in pool:
		if is_instance_valid(enemy) and not enemy.active:
			return enemy
	# Si hace falta, expandimos
	var enemy = enemy_scene.instantiate()
	enemy.hide()
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.active = false
	enemy.is_dead = true
	if enemy.has_method("_disable_collisions_now"):
		enemy._disable_collisions_now()
	add_child(enemy)
	pool.append(enemy)
	return enemy
