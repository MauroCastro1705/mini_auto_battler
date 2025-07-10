extends CharacterBody2D
# Parámetros de movimiento
@export var speed: float = 50.0
@onready var focal_point: Marker2D = $"../focal_point"
var life:int = 3
signal enemy_died

func _ready():
	add_to_group("enemigos")
	go_to_center()
	
func _physics_process(_delta):
	move_and_slide()

func go_to_center():
	var target = focal_point.global_position
	var direction = (target - global_position).normalized()
	velocity = direction * speed

func take_damage(damage:int):
	life -= damage
	if life <= 0:
		die()
		
func die():
	Global.enemy_killed.emit()
	queue_free()
