extends CharacterBody2D
# Parámetros de movimiento
var speed
var max_hp
var hp
var active = false
var is_dead = false
@onready var damage_numbers_origin: Node2D = $damage_numbers_origin
@onready var sprite: ColorRect = $ColorRect
@onready var progress_bar: ProgressBar = $ProgressBar

#----------------------------
#COMO MOSTRAR NUMEROS DE DAÑO
#usar funcion = DamageNumbers.display_numbers(value, damage_numbers_origin.global_position)
#el VALUE es el daño que recibio
#damage_numbers_origin.global_position = es solo el nodo donde va a mostrar el numero
#----------------------------


func _ready():
	add_to_group("enemigos")
	speed = Global.enemigo_speed
	max_hp = Global.enemigo_max_hp
	Global.enemy_killed.connect(check_upgrade_mob)
	hp = max_hp
	update_lifebar()
	
func _process(_delta):
	if not active:
		return
	if Global.player and is_instance_valid(Global.player):
		var dir = (Global.player.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()


func activate(pos: Vector2):
	update_lifebar()
	global_position = pos
	hp = Global.enemigo_max_hp
	is_dead = false
	active = true
	show()
	set_process(true)

func deactivate():
	active = false
	is_dead = true
	hide()
	set_process(false)

	# Inform player we're out of range (if needed)
	if Global.player:
		Global.player.remove_enemy(self)

func take_damage(amount):
	if not active or is_dead:
		return
	hp -= amount
	update_lifebar()
	DamageNumbers.display_numbers(amount, damage_numbers_origin.global_position)
	DamageNumbers.flash_sprite(sprite)
	if hp <= 0:
		is_dead = true
		Global.emit_signal("enemy_killed")
		deactivate()

func update_lifebar():
	progress_bar.value = hp
	progress_bar.max_value = max_hp
	
func check_upgrade_mob():
	if Global.level == 2:
		sprite.color = Color(0.2,0.2,0.2,1)
		sprite.scale = Vector2(1.5, 1.5)
		Global.upgrade_mob()
