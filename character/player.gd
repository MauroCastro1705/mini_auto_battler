extends CharacterBody2D

@onready var atk_timer: Timer = $atk_timer
@onready var bullet_pool: Node = $BulletPool
@onready var atk_range: CollisionShape2D = $enemy_detector/CollisionShape2D
@onready var crosshair: Sprite2D = $Crosshair

@export var draw_range:bool = false
var enemies_in_range: Array[Node] = []

var auto_target_enabled := false
var crosshair_active := false
const SHOOT_MODE_CLICK := 0# normal shoot
const SHOOT_MODE_AIM := 1 # auto-shoot but aiming via crosshair
const SHOOT_MODE_AUTO := 2 # auto-shoot and auto-aim nearest enemy

@export var shoot_mode: int = SHOOT_MODE_AIM ##shoot mode 0 is click,mode 1 is aiming,mode 2 is full auto


var can_shoot := true
var pending_click_target: Vector2 = Vector2.ZERO
var has_pending_click: bool = false

func _ready() -> void:
	Global.player = self
	Global.stats_updated.connect(update_global)
	update_global() # Initial call
	#queue_redraw()
	atk_timer.wait_time = Global.attack_cooldown
	atk_timer.start()

func update_global() -> void:
	atk_timer.wait_time = Global.attack_cooldown
	atk_timer.start()
	print("atk cooldown:" , Global.attack_cooldown)
	if atk_range.shape is CircleShape2D:
		(atk_range.shape as CircleShape2D).radius = Global.atk_range

func _process(_delta: float) -> void:
	#queue_redraw()

	# Support action-based touch input named "finger_touch" (can be mapped to mouse for debugging)
	var cam := get_viewport().get_camera_2d()
	# Handle just-pressed action (useful for mouse-mapped debugging clicks)
	if Input.is_action_just_pressed("finger_touch"):
		var click_pos: Vector2
		if cam:
			click_pos = cam.unproject_position(get_viewport().get_mouse_position())
		else:
			click_pos = get_global_mouse_position()
		#print("[Player] finger_touch just pressed at", click_pos)
		if shoot_mode == SHOOT_MODE_CLICK:
			pending_click_target = click_pos
			has_pending_click = true
			crosshair.global_position = click_pos
			crosshair.visible = true
			crosshair_active = true

	if Input.is_action_pressed("finger_touch"):
		var world_pos: Vector2
		if cam:
			world_pos = cam.unproject_position(get_viewport().get_mouse_position())
		else:
			world_pos = get_global_mouse_position()
		crosshair.global_position = world_pos
		crosshair.visible = true
		crosshair_active = true
	else:
		# If action not pressed: hide crosshair only in AUTO mode, otherwise keep it visible
		if not Input.is_action_pressed("finger_touch"):
			if shoot_mode == SHOOT_MODE_AUTO:
				crosshair_active = false
				crosshair.visible = false
			elif shoot_mode == SHOOT_MODE_CLICK:
				# keep crosshair visible but only active if there's a pending click
				crosshair_active = has_pending_click
				crosshair.visible = true
			elif shoot_mode == SHOOT_MODE_AIM:
				# keep crosshair visible but inactive until touch press
				crosshair_active = false
				crosshair.visible = true
	# If player is using the crosshair, face it; otherwise face nearest enemy (if auto-target enabled)
	if crosshair_active and is_instance_valid(crosshair) and crosshair.visible:
		look_at(crosshair.global_position)
	else:
		var target := get_nearest_enemy()
		if is_instance_valid(target) and auto_target_enabled:
			look_at(target.global_position)

func get_nearest_enemy() -> Node:
	var nearest: Node = null
	var min_dist := INF

	# Limpia la lista de cualquier referencia inválida o inactiva
	var filtered: Array[Node] = []
	for enemy in enemies_in_range:
		if is_instance_valid(enemy) and enemy.active:
			filtered.append(enemy)
	enemies_in_range = filtered

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
	
func _on_atk_timer_timeout() -> void:
	can_shoot = true
	# Timer elapsed: attempt auto shot depending on mode
	print("[Player] atk_timer timeout -> can_shoot set to", can_shoot)
	shoot()

func shoot() -> void:
	if not can_shoot:
		print("[Player] shoot aborted: can_shoot is false")
		return

	var direction := Vector2.ZERO

	match shoot_mode:
		SHOOT_MODE_CLICK:
			# In click mode, shoot toward the pending click target when timer allows
			if not has_pending_click:
				return
			# compute direction from pending target
			direction = (pending_click_target - global_position)
			has_pending_click = false
			# keep crosshair visible in CLICK mode (only hide in AUTO mode)
		SHOOT_MODE_AIM:
			# Only shoot when player placed a crosshair
			if crosshair_active and is_instance_valid(crosshair) and crosshair.visible:
				direction = (crosshair.global_position - global_position)
				if direction.length_squared() == 0:
					return
				direction = direction.normalized()
			else:
				return
		SHOOT_MODE_AUTO:
			# Auto-aim nearest enemy (full auto)
			var target := get_nearest_enemy()
			if not is_instance_valid(target):
				return
			direction = (target.global_position - global_position).normalized()

	# Get bullet from pool and fire
	var bullet = bullet_pool.get_bullet()
	if bullet:
		if bullet.has_method("fire"):
			bullet.fire(global_position, direction)
			can_shoot = false
		else:
			print("[Player] bullet has no fire() method")
	else:
		print("[Player] no bullet available from pool")


func _attempt_shoot_direction(direction: Vector2) -> void:
	if not can_shoot:
		return
	if direction.length_squared() == 0:
		return
	direction = direction.normalized()
	var bullet = bullet_pool.get_bullet()
	if bullet and bullet.has_method("fire"):
		bullet.fire(global_position, direction)
		can_shoot = false

func _on_enemy_detector_body_entered(body: Node) -> void:
	if body.is_in_group("enemigos") and body not in enemies_in_range:
		enemies_in_range.append(body)

func _on_enemy_detector_body_exited(body: Node) -> void:
	enemies_in_range.erase(body)

func enable_auto_target(enable: bool) -> void:
	auto_target_enabled = enable

func set_shoot_mode(mode: int) -> void:
	## modos validos: 0 = click, 1 = aim, 2 = auto
	if mode in [SHOOT_MODE_CLICK, SHOOT_MODE_AIM, SHOOT_MODE_AUTO]:
		shoot_mode = mode
		print("[Player] shoot_mode set to", mode)
		# auto-enable auto_target when switching to full auto
		if mode == SHOOT_MODE_AUTO:
			auto_target_enabled = true
		# adjust crosshair visibility based on mode
		if mode == SHOOT_MODE_AUTO:
			crosshair.visible = false
			crosshair_active = false
		else:
			crosshair.visible = true
			crosshair_active = true
	else:
		print("[Player] set_shoot_mode: invalid mode", mode)

func _input(event) -> void:
	var cam := get_viewport().get_camera_2d()
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			var world_pos: Vector2
			if cam:
				world_pos = cam.unproject_position(touch.position)
			else:
				world_pos = get_global_mouse_position()
			# Behavior depends on shooting mode
			if shoot_mode == SHOOT_MODE_CLICK:
				# Register pending click target; actual shot occurs on timer
				pending_click_target = world_pos
				has_pending_click = true
				# show crosshair as feedback until shot
				crosshair.global_position = world_pos
				crosshair.visible = true
				crosshair_active = true
			else:
				crosshair.global_position = world_pos
				crosshair.visible = true
				crosshair_active = true
		else:
			# On touch release: hide only in AUTO mode, otherwise keep crosshair visible
			if shoot_mode == SHOOT_MODE_AUTO:
				crosshair_active = false
				crosshair.visible = false
			else:
				crosshair_active = true
				crosshair.visible = true
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		var world_pos: Vector2
		if cam:
			world_pos = cam.unproject_position(drag.position)
		else:
			world_pos = get_global_mouse_position()
		# Update crosshair during drag only for AIM mode
		if shoot_mode == SHOOT_MODE_AIM:
			crosshair.global_position = world_pos
			crosshair.visible = true
			crosshair_active = true

func _draw():
	if draw_range:
		var radius = atk_range.shape.radius
		var color = Color(0, 0, 1, 0.3)
		var thickness = 2.0  # Thickness of the outline
		var angle_from = 0
		var angle_to = TAU  # Full circle (2 * PI)
		var point_count = 64  # More points = smoother circle
	
		draw_arc(Vector2.ZERO, radius, angle_from, angle_to, point_count, color, thickness)
