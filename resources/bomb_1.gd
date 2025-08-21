extends CharacterBody2D


var damage:int = 10
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_collision: CollisionShape2D = $explosion_area/CollisionShape2D
@onready var bomb_reticule: Node2D = %bomb_reticule
@onready var show_bomb: Button = $CanvasLayer/show_bomb
@onready var launch_boomb: Button = $CanvasLayer/launch_boomb


var speed:float = 400.0

# --- Controles táctiles ---
var _is_touching := false
var _touch_pos: Vector2 = Vector2.ZERO
var _deadzone_px := 12.0  # evita “temblequeo” cuando el dedo está casi encima

func _ready() -> void:
	sprite.hide()
	bomb_reticule.hide()
	
func _input(event: InputEvent) -> void:
	# Pulsa pantalla
	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			_is_touching = true
			_touch_pos = st.position
		else:
			_is_touching = false
			velocity = Vector2.ZERO

	elif event is InputEventScreenDrag:# Arrastra dedo
		var sd := event as InputEventScreenDrag
		_is_touching = true
		_touch_pos = sd.position

func _physics_process(_delta: float) -> void:
	# Disparo/bomba: mantené el mapeo de "shoot" en Input Map o botón UI
	if Input.is_action_just_pressed("shoot"):
		explode()

	get_input()
	move_and_slide()

func update_bomb_ui():
	if Global.player_bombs < 1:
		launch_boomb.text = "no bombs left"
	else:
		launch_boomb.text = "Launch Bomb"


func get_input() -> void:
	if _is_touching:
		# Mover hacia la posición del dedo
		var to_finger := (_touch_pos - global_position)
		if to_finger.length() > _deadzone_px:
			velocity = to_finger.normalized() * speed
		else:
			velocity = Vector2.ZERO
	else:
		# Teclado / gamepad (PC)
		var input_direction := Input.get_vector("izq", "der", "arriba", "abajo")
		velocity = input_direction * speed

func explode() -> void:
	update_bomb_ui()
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

func set_bomb_params() -> void:
	sprite.scale = Global.player_bomb_size
	sprite_collision.scale = Global.player_bomb_size
	damage = Global.player_bomb_dmg

func _on_animated_sprite_2d_animation_finished() -> void:
	sprite.hide()
	speed = 400
	bomb_reticule.hide()


func _on_button_pressed() -> void:
	bomb_reticule.show()


func _on_launch_boomb_pressed() -> void:
	explode()
