extends CharacterBody2D
# Parámetros de movimiento
@export var speed: float = 50.0
@export var max_hp:float = 3.0
var hp:float = 3.0
var active = false

func _ready():
	add_to_group("enemigos")

	
func _process(delta):
	if not active:
		return

	if Global.player and is_instance_valid(Global.player):
		var dir = (Global.player.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()


func activate(spawn_position: Vector2):
	global_position = spawn_position
	hp = max_hp
	active = true
	show()
	set_process(true)

func deactivate():
	active = false
	hide()
	set_process(false)

func take_damage(damage:int):
	hp -= damage
	if hp <= 0:
		die()

func die():
	Global.enemy_killed.emit()
	deactivate()
	   
		
