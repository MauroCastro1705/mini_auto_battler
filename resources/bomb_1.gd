extends CharacterBody2D

var damage:int = 10
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_collision: CollisionShape2D = $explosion_area/CollisionShape2D
@onready var bomb_reticule: Node2D = %bomb_reticule
@onready var show_bomb: Button = $CanvasLayer/show_bomb
@onready var launch_boomb: Button = $CanvasLayer/launch_boomb  # ojo al nombre en la escena

var speed:float = 400.0

# --- Controles táctiles ---
var _is_touching := false
var _touch_pos: Vector2 = Vector2.ZERO
var _deadzone_px := 12.0

# --- NUEVO: estado de apuntado ---
var is_aiming := false

func _ready() -> void:
	sprite.hide()
	bomb_reticule.hide()
	# Al inicio no podés lanzar hasta mostrar la retícula
	launch_boomb.disabled = true
	update_bomb_ui()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			_is_touching = true
			_touch_pos = st.position
		else:
			_is_touching = false
			velocity = Vector2.ZERO

	elif event is InputEventScreenDrag:
		var sd := event as InputEventScreenDrag
		_is_touching = true
		_touch_pos = sd.position

func _physics_process(_delta: float) -> void:
	# Si querés permitir teclado/acción para lanzar, solo cuando está apuntando:
	if Input.is_action_just_pressed("shoot") and is_aiming:
		_attempt_launch()

	get_input()
	move_and_slide()

func update_bomb_ui():
	if Global.player_bombs < 1:
		launch_boomb.text = "No bombs left"
		launch_boomb.disabled = true
	else:
		launch_boomb.text = "Launch Bomb"
		# Solo habilitar si estamos apuntando
		launch_boomb.disabled = not is_aiming

	# Botón de mostrar/ocultar retícula
	show_bomb.text = "Cancel" if is_aiming else "Show Bomb"

func get_input() -> void:
	if _is_touching:
		var to_finger := (_touch_pos - global_position)
		velocity = to_finger.normalized() * speed if to_finger.length() > _deadzone_px else Vector2.ZERO
	else:
		var input_direction := Input.get_vector("izq", "der", "arriba", "abajo")
		velocity = input_direction * speed

# ------------------ LÓGICA BOMBA ------------------

# Lanza la bomba SOLO si estamos apuntando y hay bombas
func _attempt_launch() -> void:
	if not is_aiming:
		print("No estás apuntando: primero presiona Show Bomb.")
		return
	if Global.player_bombs < 1:
		print("No hay bombas disponibles.")
		return
	explode()

func explode() -> void:
	# Seguridad extra
	if Global.player_bombs < 1:
		print("no hay bombas disponibles")
		speed = 400
		return

	speed = 0
	set_bomb_params()
	sprite.show()
	sprite.play("explosion")
	Global.player_bombs -= 1
	Global.emit_signal("bomb_droped")

	# Daño a enemigos dentro del área
	var bodies = $explosion_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(damage)

	# Salimos de modo apuntado y actualizamos UI
	is_aiming = false
	bomb_reticule.hide()
	update_bomb_ui()

func set_bomb_params() -> void:
	sprite.scale = Global.player_bomb_size
	sprite_collision.scale = Global.player_bomb_size
	damage = Global.player_bomb_dmg

func _on_animated_sprite_2d_animation_finished() -> void:
	sprite.hide()
	speed = 400
	# La retícula ya se ocultó en explode(); no repetir.

# --------- HANDLERS DE BOTONES ---------

# Mostrar/ocultar retícula y armar/desarmar lanzamiento
func _on_button_pressed() -> void:
	# Este es el handler de show_bomb
	if is_aiming:
		# Cancelar apuntado
		is_aiming = false
		bomb_reticule.hide()
	else:
		# Entrar en modo apuntado solo si hay bombas
		if Global.player_bombs < 1:
			print("No hay bombas para apuntar.")
			is_aiming = false
			bomb_reticule.hide()
		else:
			is_aiming = true
			bomb_reticule.show()
	update_bomb_ui()

func _on_launch_boomb_pressed() -> void:
	_attempt_launch()
