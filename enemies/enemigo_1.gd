extends CharacterBody2D
# Parámetros de movimiento
@export var speed: float = 50.0
@export var max_hp:float = 3.0
var hp:float = 3.0
var active = false
var is_dead = false

func _ready():
	add_to_group("enemigos")

	
func _process(delta):
	if not active:
		return

	if Global.player and is_instance_valid(Global.player):
		var dir = (Global.player.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()


func activate(pos: Vector2):
	global_position = pos
	hp = max_hp
	is_dead = false
	active = true
	show()
	set_process(true)

func deactivate():
	active = false
	hide()
	set_process(false)

func take_damage(amount):
	if not active or is_dead:
		return
	hp -= amount
	if hp <= 0:
		is_dead = true
		Global.emit_signal("enemy_killed")
		deactivate()
