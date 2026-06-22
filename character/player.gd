extends CharacterBody2D

@onready var atk_timer: Timer = $atk_timer
@onready var bullet_pool: Node = $BulletPool
@onready var atk_range: CollisionShape2D = $enemy_detector/CollisionShape2D
@onready var crosshair: Sprite2D = $Crosshair
@onready var movement_crosshair: Sprite2D = $Movement_crosshair

@export var draw_range:bool = false
var enemies_in_range: Array[Node] = []

# Movement / RTS-style hold-to-move
@export var move_speed: float = 200.0
var move_target: Vector2 = Vector2.ZERO
var moving: bool = false
@export var dot_spacing: float = 18.0
@export var dot_radius: float = 2.0
@export var dot_color: Color = Color(1, 1, 1, 0.9)

# Movement crosshair pulse animation
@export var move_pulse_speed: float = 6.0
@export var move_pulse_scale: float = 1.6
var _move_pulse_time: float = 0.0
@export var move_pulse_alpha_min: float = 0.6
@export var move_pulse_alpha_max: float = 1.0
@onready var engine_animation: AnimatedSprite2D = $"Nairan-Battlecruiser-Base/engine_animation"
@onready var shield_animation: AnimatedSprite2D = $"Nairan-Battlecruiser-Base/shield_animation"

# Hold-to-move settings
@export var hold_threshold: float = 0.3
var _hold_timer: float = 0.0
var _pressing: bool = false
var _hold_started: bool = false

var auto_target_enabled := false
var crosshair_active := false
var _movement_original_parent: Node = null
var _movement_original_index: int = -1
var movement_path: Line2D = null
const SHOOT_MODE_CLICK := 0# normal shoot
const SHOOT_MODE_AIM := 1 # auto-shoot but aiming via crosshair
const SHOOT_MODE_AUTO := 2 # auto-shoot and auto-aim nearest enemy
var world_pos: Vector2
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
	# ensure engine animation is off until we move
	if is_instance_valid(engine_animation):
		engine_animation.hide()

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
		# start press/hold timer; movement will begin after threshold
		_pressing = true
		_hold_timer = 0.0
		_hold_started = false
		#update()

	if Input.is_action_pressed("finger_touch"):
		
		if cam:
			world_pos = cam.unproject_position(get_viewport().get_mouse_position())
		else:
			world_pos = get_global_mouse_position()
		# update shooting crosshair
		crosshair.global_position = world_pos
		crosshair.visible = true
		crosshair_active = true
		# handle hold-to-move timer
		if _pressing and not _hold_started:
			_hold_timer += _delta
			if _hold_timer >= hold_threshold:
				# begin movement
				_hold_started = true
				_ensure_movement_crosshair_world_parent()
				movement_crosshair.global_position = world_pos
				movement_crosshair.visible = true
				move_target = world_pos
				moving = true
		# while holding after start, update target
		elif _hold_started:
			movement_crosshair.global_position = world_pos
			move_target = world_pos

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
			# stop pressing state on release; if hold started, stop movement now
			_pressing = false
			if _hold_started:
				_hold_started = false
				moving = false
				movement_crosshair.visible = false
				_restore_movement_crosshair_parent()
				_remove_movement_path()
	# If player is using the crosshair, face it; otherwise face nearest enemy (if auto-target enabled)
	if crosshair_active and is_instance_valid(crosshair) and crosshair.visible:
		look_at(crosshair.global_position)
	else:
		var target := get_nearest_enemy()
		if is_instance_valid(target) and auto_target_enabled:
			look_at(target.global_position)

	# Animate movement crosshair when visible
	if is_instance_valid(movement_crosshair) and movement_crosshair.visible:
		_move_pulse_time += _delta * move_pulse_speed
		var t := (sin(_move_pulse_time) * 0.5) + 0.5 # 0..1
		var scale_val = lerp(1.3, move_pulse_scale, t)
		movement_crosshair.scale = Vector2.ONE * scale_val
		# modulate alpha
		var col := movement_crosshair.modulate
		col.a = lerp(move_pulse_alpha_min, move_pulse_alpha_max, t)
		movement_crosshair.modulate = col

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
			# Movement: start press/hold timer; movement begins after threshold
			_pressing = true
			_hold_timer = 0.0
			_hold_started = false
			# Behavior depends on shooting mode
			if shoot_mode == SHOOT_MODE_CLICK:
				# Register pending click target; actual shot occurs on timer
				pending_click_target = world_pos
				has_pending_click = true
				# show crosshair as feedback until shot
				crosshair.global_position = world_pos
				crosshair.visible = true
			# on release stop pressing; if hold started, stop movement now
			_pressing = false
			if _hold_started:
				_hold_started = false
				moving = false
				movement_crosshair.visible = false
				_restore_movement_crosshair_parent()
				_remove_movement_path()
			else:
				crosshair.global_position = world_pos
				crosshair.visible = true
				crosshair_active = true
			# Movement: show and set movement target while touch is pressed
			_ensure_movement_crosshair_world_parent()
			movement_crosshair.global_position = world_pos
			movement_crosshair.visible = true
			move_target = world_pos
			moving = true
		else:
			return
			# On touch release: hide only in AUTO mode, otherwise keep crosshair visible
		# Update movement target while dragging only if hold started
		if _hold_started:
			_ensure_movement_crosshair_world_parent()
			movement_crosshair.global_position = world_pos
			movement_crosshair.visible = true
			move_target = world_pos
			moving = true
			# keep moving toward set destination; stop only when reached
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if cam:
			world_pos = cam.unproject_position(drag.position)
		else:
			world_pos = get_global_mouse_position()
		# Update crosshair during drag only for AIM mode
		if shoot_mode == SHOOT_MODE_AIM:
			crosshair.global_position = world_pos
			crosshair.visible = true
			crosshair_active = true
		# Update movement target while dragging
		_ensure_movement_crosshair_world_parent()
		movement_crosshair.global_position = world_pos
		movement_crosshair.visible = true
		move_target = world_pos
		moving = true


func _draw():
	if draw_range:
		var radius = atk_range.shape.radius
		var color = Color(0, 0, 1, 0.3)
		var thickness = 2.0  # Thickness of the outline
		var angle_from = 0
		var angle_to = TAU  # Full circle (2 * PI)
		var point_count = 64  # More points = smoother circle
	
		draw_arc(Vector2.ZERO, radius, angle_from, angle_to, point_count, color, thickness)

	# Draw dotted path toward movement target (in local coordinates)
	if moving and move_target != Vector2.ZERO:
		var local_target := to_local(move_target)
		var dir := local_target
		var dist := dir.length()
		if dist > 0.001:
			var dir_norm := dir.normalized()
			var step := dot_spacing
			var pos := dir_norm * (step * 0.5)
			var count := int(dist / step)
			for i in range(count):
				draw_circle(pos, dot_radius, dot_color)
				pos += dir_norm * step


func _physics_process(delta: float) -> void:
	# Handle smooth movement toward the held target
	if moving:
		var remaining := global_position.distance_to(move_target)
		if remaining <= move_speed * delta:
			global_position = move_target
			moving = false
			movement_crosshair.visible = false
			_restore_movement_crosshair_parent()
			_remove_movement_path()
		else:
			global_position = global_position.move_toward(move_target, move_speed * delta)
			look_at(move_target)
		# Update path while moving
		_update_movement_path()

	# Toggle engine animation visibility based on moving state
	if is_instance_valid(engine_animation):
		if moving:
			engine_animation.show()
		else:
			engine_animation.hide()



func _ensure_movement_crosshair_world_parent() -> void:
	if not is_instance_valid(movement_crosshair):
		return
	# store original parent/index first time
	if _movement_original_parent == null and is_instance_valid(movement_crosshair.get_parent()):
		_movement_original_parent = movement_crosshair.get_parent()
		_movement_original_index = _movement_original_parent.get_children().find(movement_crosshair)
	# move to scene root so it doesn't inherit player transforms
	var scene_root = get_tree().get_current_scene()
	if scene_root == null:
		scene_root = get_tree().get_root()
	if movement_crosshair.get_parent() != scene_root:
		movement_crosshair.get_parent().remove_child(movement_crosshair)
		scene_root.add_child(movement_crosshair)
	# ensure movement_path exists when crosshair is world-parented
	_ensure_movement_path()


func _restore_movement_crosshair_parent() -> void:
	if not is_instance_valid(movement_crosshair):
		return
	if _movement_original_parent and is_instance_valid(_movement_original_parent):
		# reparent back to original parent and restore local position (optional)
		if movement_crosshair.get_parent() != _movement_original_parent:
			movement_crosshair.get_parent().remove_child(movement_crosshair)
			_movement_original_parent.add_child(movement_crosshair)
			# restore local position to player's local coords near player
			movement_crosshair.position = to_local(global_position)
	# clear stored parent so future scene loads work properly
	_movement_original_parent = null
	_movement_original_index = -1
	_remove_movement_path()


func _ensure_movement_path() -> void:
	if movement_path and is_instance_valid(movement_path):
		return
	var scene_root = get_tree().get_current_scene()
	if scene_root == null:
		scene_root = get_tree().get_root()
	movement_path = Line2D.new()
	movement_path.width = dot_radius * 2.0
	movement_path.default_color = dot_color
	# add to scene root and set its transform origin to (0,0)
	scene_root.add_child(movement_path)
	movement_path.position = Vector2.ZERO


func _update_movement_path() -> void:
	if not moving:
		_remove_movement_path()
		return
	if not is_instance_valid(movement_path):
		_ensure_movement_path()
	if not is_instance_valid(movement_path):
		return
	# sample points from player global_position to move_target
	var start := global_position
	var dir := (move_target - start)
	var dist := dir.length()
	if dist <= 0.001:
		_remove_movement_path()
		return
	var dir_n := dir / dist
	var step := dot_spacing
	var count := int(dist / step) + 1
	var pts: PackedVector2Array = PackedVector2Array()
	for i in range(count + 1):
		var p_global = start + dir_n * clamp(i * step, 0, dist)
		pts.append(movement_path.to_local(p_global))
	movement_path.points = pts


func _remove_movement_path() -> void:
	if movement_path and is_instance_valid(movement_path):
		movement_path.queue_free()
		movement_path = null
