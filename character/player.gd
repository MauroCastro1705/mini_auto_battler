extends CharacterBody2D

@onready var atk_timer: Timer = $atk_timer
@onready var bullet_pool: Node = $BulletPool
@onready var atk_range: CollisionShape2D = $enemy_detector/CollisionShape2D
@onready var crosshair: Sprite2D = $Crosshair
@onready var engine_animation: AnimatedSprite2D = $"Nairan-Battlecruiser-Base/engine_animation"
@onready var shield_animation: AnimatedSprite2D = $"Nairan-Battlecruiser-Base/shield_animation"

@export var draw_range: bool = false
var enemies_in_range: Array[Node] = []

@export var mining_rate: float = 20.0
@export var mining_range: float = 80.0
var mining_target: Node2D = null

var auto_target_enabled := false
var crosshair_active := false

const SHOOT_MODE_CLICK := 0  # dispara al hacer click
const SHOOT_MODE_AIM   := 1  # apunta con crosshair, dispara automático
const SHOOT_MODE_AUTO  := 2  # auto-apunta al enemigo más cercano

@export var shoot_mode: int = SHOOT_MODE_AIM

var can_shoot := true
var pending_click_target: Vector2 = Vector2.ZERO
var has_pending_click: bool = false


func _ready() -> void:
	Global.player = self
	Global.stats_updated.connect(update_global)
	update_global()
	atk_timer.wait_time = Global.attack_cooldown
	atk_timer.start()
	if is_instance_valid(engine_animation):
		engine_animation.hide()
	crosshair.visible = false


func update_global() -> void:
	atk_timer.wait_time = Global.attack_cooldown
	atk_timer.start()
	print("atk cooldown:", Global.attack_cooldown)
	if atk_range.shape is CircleShape2D:
		(atk_range.shape as CircleShape2D).radius = Global.atk_range


func _process(delta: float) -> void:
	# Apuntar según el modo
	if shoot_mode == SHOOT_MODE_AUTO:
		var target := get_nearest_enemy()
		if is_instance_valid(target) and auto_target_enabled:
			look_at(target.global_position)
	elif crosshair_active and is_instance_valid(crosshair) and crosshair.visible:
		look_at(crosshair.global_position)

	if Input.is_action_pressed("ui_accept"):
		_try_mine(delta)


func _screen_to_world(screen_pos: Vector2) -> Vector2:
	var cam := get_viewport().get_camera_2d()
	if cam:
		return get_viewport().get_canvas_transform().affine_inverse() * screen_pos
	return get_canvas_transform().affine_inverse() * screen_pos


func _unhandled_input(event: InputEvent) -> void:
	var world: Vector2

	# ── Touch (Android) ──────────────────────────────────────────────
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		world = _screen_to_world(touch.position)

		if touch.pressed:
			crosshair.global_position = world
			crosshair.visible = true
			crosshair_active = true

			if shoot_mode == SHOOT_MODE_CLICK:
				pending_click_target = world
				has_pending_click = true

		else:
			crosshair_active = false
			if shoot_mode != SHOOT_MODE_CLICK:
				crosshair.visible = false

	# ── Drag touch (Android) — actualiza el crosshair mientras arrastrás ──
	elif event is InputEventScreenDrag:
		world = _screen_to_world((event as InputEventScreenDrag).position)
		crosshair.global_position = world
		crosshair.visible = true
		crosshair_active = true

		if shoot_mode == SHOOT_MODE_CLICK:
			pending_click_target = world
			has_pending_click = true

	# ── Mouse click izquierdo (PC) ────────────────────────────────────
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		world = _screen_to_world(mb.position)

		if mb.pressed:
			crosshair.global_position = world
			crosshair.visible = true
			crosshair_active = true

			if shoot_mode == SHOOT_MODE_CLICK:
				pending_click_target = world
				has_pending_click = true

		else:
			crosshair_active = false
			if shoot_mode != SHOOT_MODE_CLICK:
				crosshair.visible = false

	# ── Mouse motion (PC) — solo actualiza si el botón está presionado ──
	elif event is InputEventMouseMotion:
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			return
		world = _screen_to_world((event as InputEventMouseMotion).position)
		crosshair.global_position = world
		crosshair.visible = true
		crosshair_active = true

		if shoot_mode == SHOOT_MODE_CLICK:
			pending_click_target = world
			has_pending_click = true


# ── Disparo ───────────────────────────────────────────────────────────────────

func _on_atk_timer_timeout() -> void:
	can_shoot = true
	shoot()


func shoot() -> void:
	if not can_shoot:
		return

	var direction := Vector2.ZERO

	match shoot_mode:
		SHOOT_MODE_CLICK:
			if not has_pending_click:
				return
			direction = (pending_click_target - global_position).normalized()
			has_pending_click = false

		SHOOT_MODE_AIM:
			if crosshair_active and is_instance_valid(crosshair) and crosshair.visible:
				direction = (crosshair.global_position - global_position)
				if direction.length_squared() == 0:
					return
				direction = direction.normalized()
			else:
				return

		SHOOT_MODE_AUTO:
			var target := get_nearest_enemy()
			if not is_instance_valid(target):
				return
			direction = (target.global_position - global_position).normalized()

	var bullet = bullet_pool.get_bullet()
	if bullet and bullet.has_method("fire"):
		bullet.fire(global_position, direction)
		can_shoot = false
	else:
		print("[Player] no bullet available from pool")


# ── Enemigos ──────────────────────────────────────────────────────────────────

func get_nearest_enemy() -> Node:
	var nearest: Node = null
	var min_dist := INF
	var filtered: Array[Node] = []
	for enemy in enemies_in_range:
		if is_instance_valid(enemy) and enemy.active:
			filtered.append(enemy)
	enemies_in_range = filtered
	for enemy in enemies_in_range:
		var dist := global_position.distance_squared_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = enemy
	return nearest


func remove_enemy(enemy: Node) -> void:
	enemies_in_range.erase(enemy)


func _on_enemy_detector_body_entered(body: Node) -> void:
	if body.is_in_group("enemigos") and body not in enemies_in_range:
		enemies_in_range.append(body)


func _on_enemy_detector_body_exited(body: Node) -> void:
	enemies_in_range.erase(body)


# ── Minería ───────────────────────────────────────────────────────────────────

func _try_mine(delta: float) -> void:
	if not is_instance_valid(mining_target):
		mining_target = _find_nearest_mineable_asteroid()
	if not is_instance_valid(mining_target):
		return
	if global_position.distance_to(mining_target.global_position) > mining_range:
		mining_target = null
		return
	if mining_target.has_method("mine"):
		mining_target.mine(mining_rate * delta)


func _find_nearest_mineable_asteroid() -> Node2D:
	var nearest: Node2D = null
	var nearest_distance := INF
	for node in get_tree().get_nodes_in_group("mineable_asteroids"):
		if not is_instance_valid(node) or not node is Node2D:
			continue
		var d := global_position.distance_squared_to(node.global_position)
		if d <= mining_range * mining_range and d < nearest_distance:
			nearest_distance = d
			nearest = node
	return nearest


# ── Modos y utilidades ────────────────────────────────────────────────────────

func enable_auto_target(enable: bool) -> void:
	auto_target_enabled = enable


func set_shoot_mode(mode: int) -> void:
	if mode in [SHOOT_MODE_CLICK, SHOOT_MODE_AIM, SHOOT_MODE_AUTO]:
		shoot_mode = mode
		print("[Player] shoot_mode set to", mode)
		if mode == SHOOT_MODE_AUTO:
			auto_target_enabled = true
			crosshair.visible = false
			crosshair_active = false
		else:
			crosshair.visible = false
			crosshair_active = false
	else:
		print("[Player] set_shoot_mode: invalid mode", mode)


func _draw() -> void:
	if draw_range:
		draw_arc(Vector2.ZERO, atk_range.shape.radius, 0, TAU, 64, Color(0, 0, 1, 0.3), 2.0)
