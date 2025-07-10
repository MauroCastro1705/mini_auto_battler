extends Node

@export var bullet_scene: PackedScene
const POOL_SIZE = 100
var pool: Array[Bullet] = []

func _ready():
	for i in range(POOL_SIZE):
		var b = bullet_scene.instantiate()
		b.hide()
		b.active = false
		add_child(b)
		pool.append(b)

func get_bullet() -> Bullet:
	for bullet in pool:
		if not bullet.active:
			return bullet
	# Optional: expand pool if needed
	var b = bullet_scene.instantiate()
	add_child(b)
	pool.append(b)
	return b
