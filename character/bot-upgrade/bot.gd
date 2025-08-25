extends CharacterBody2D


@onready var bullet_pool: Node = $BulletPool
@onready var atk_timer: Timer = $Timer
@onready var atk_range: CollisionShape2D = $Enemy_detector/CollisionShape2D
@onready var propulsor: AnimatedSprite2D = $Node2D/propulsor
@onready var ship: AnimatedSprite2D = $Node2D/ship

var enemies_in_range: Array[Node] = []

var show_range := true

func _ready() -> void:
	Global.stats_updated.connect(update_global)
	update_global() # Initial call
	queue_redraw()
	atk_timer.wait_time = Global.bot_atk_cooldown
	atk_timer.start()
	propulsor.play("jet")

func update_global() -> void:
	atk_timer.wait_time = Global.bot_atk_cooldown
	atk_timer.start()
	print("atk cooldown:" , Global.bot_atk_cooldown)
	if atk_range.shape is CircleShape2D:
		(atk_range.shape as CircleShape2D).radius = Global.bot_atk_range

func _process(_delta: float) -> void:
	queue_redraw()
	var target := get_nearest_enemy()
	if is_instance_valid(target):
		look_at(target.global_position)

func get_nearest_enemy() -> Node:
	var nearest: Node = null
	var min_dist := INF

	# Limpia la lista de cualquier referencia inválida o inactiva
	enemies_in_range = enemies_in_range.filter(func(enemy: Node) -> bool:
		return is_instance_valid(enemy) and enemy.active
	)

	for enemy in enemies_in_range:
		# (enemy.active ya garantizado por el filter)
		var dist := global_position.distance_squared_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = enemy
			
	return nearest

func remove_enemy(enemy: Node) -> void:
	# Llamada desde Enemy.deactivate() para garantizar limpieza aunque no haya body_exited
	enemies_in_range.erase(enemy)
	


func shoot() -> void:
	var target := get_nearest_enemy()
	if not is_instance_valid(target):
		return

	var direction = (target.global_position - global_position).normalized()

	# Defensivo: chequea que el pool devolvió algo y que tiene el método fire
	var bullet = bullet_pool.get_bullet()
	if bullet and bullet.has_method("fire"):
		bullet.fire(global_position, direction)

func _on_enemy_detector_body_entered(body: Node) -> void:
	if body.is_in_group("enemigos") and body not in enemies_in_range:
		enemies_in_range.append(body)


func _on_enemy_detector_body_exited(body: Node2D) -> void:
	enemies_in_range.erase(body)
	
func _draw():
	var radius = atk_range.shape.radius
	var color = Color(0, 0, 1, 0.3)
	var thickness = 2.0  # Thickness of the outline
	var angle_from = 0
	var angle_to = TAU  # Full circle (2 * PI)
	var point_count = 64  # More points = smoother circle

	draw_arc(Vector2.ZERO, radius, angle_from, angle_to, point_count, color, thickness)


func _on_timer_timeout() -> void:
	shoot()
