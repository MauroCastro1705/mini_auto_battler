extends CharacterBody2D
# Parámetros de movimiento
@export var speed: float = 200.0
@export var jump_velocity: float = -400.0

func _ready():
	add_to_group("enemigos")

func _physics_process(_delta):

	# Movimiento horizontal
	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = direction * speed

	# Mover al personaje
	move_and_slide()
