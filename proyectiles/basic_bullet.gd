extends Node2D
class_name Bullet

@export var speed: float = 400
@export var damage: int = 10
var direction: Vector2
var active := false
var lifetime := 2.0
var time_alive := 0.0

func _ready():
	hide()

func fire(fire_position: Vector2, dir: Vector2, dmg: int = 10):
	global_position = fire_position
	direction = dir.normalized()
	damage = dmg
	time_alive = 0.0
	active = true
	show()

func _process(delta):
	if not active:
		return
	position += direction * speed * delta
	time_alive += delta
	if time_alive > lifetime:
		deactivate()

func deactivate():
	active = false
	hide()
