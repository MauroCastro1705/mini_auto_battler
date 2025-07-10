extends CharacterBody2D
# Parámetros de movimiento
@export var speed: float = 50.0
@onready var focal_point: Marker2D = $"../focal_point"

func _ready():
	add_to_group("enemigos")
	go_to_center()
	
func _physics_process(_delta):
	move_and_slide()

func go_to_center():
	var target = focal_point.global_position
	var direction = (target - global_position).normalized()
	velocity = direction * speed
