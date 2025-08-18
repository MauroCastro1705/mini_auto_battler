extends CharacterBody2D

@onready var atk_timer: Timer = $atk_timer
@onready var bullet_pool: Node = $BulletPool
@onready var atk_range: CollisionShape2D = $enemy_detector/CollisionShape2D

var enemies_in_range: Array[Node] = []
var shoot_cooldown := 0.8
var time_since_shot := 0.0

var show_range := true

func _ready() -> void:
	Global.player = self
	Global.stats_updated.connect(update_global)
	update_global() # Initial call
	queue_redraw()

func update_global() -> void:
	shoot_cooldown = max(0.05, Global.attack_speed) # pequeño clamp defensivo
	if atk_range.shape is CircleShape2D:
		(atk_range.shape as CircleShape2D).radius = Global.atk_range

func _process(delta: float) -> void:
	queue_redraw()
	time_since_shot += delta

	var target := get_nearest_enemy()
	if is_instance_valid(target):
		look_at(target.global_position)

	if time_since_shot >= shoot_cooldown:
		shoot()
		time_since_shot = 0.0

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

func _on_enemy_detector_body_exited(body: Node) -> void:
	enemies_in_range.erase(body)


func _draw():
	var radius = atk_range.shape.radius
	var color = Color(0, 0, 1, 0.3)
	var thickness = 2.0  # Thickness of the outline
	var angle_from = 0
	var angle_to = TAU  # Full circle (2 * PI)
	var point_count = 64  # More points = smoother circle

	draw_arc(Vector2.ZERO, radius, angle_from, angle_to, point_count, color, thickness)
