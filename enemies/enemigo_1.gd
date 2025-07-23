extends CharacterBody2D
# Parámetros de movimiento
var speed
var max_hp
var hp
var active = false
var is_dead = false
@onready var damage_numbers_origin: Node2D = $damage_numbers_origin
@onready var ship_sprite = %ship
@onready var health_bar: Control = %HealthBar
@onready var ship: Node2D = $Node2D
@onready var propulsor: AnimatedSprite2D = %propulsor

#----------------------------
#COMO MOSTRAR NUMEROS DE DAÑO
#usar funcion = DamageNumbers.display_numbers(value, damage_numbers_origin.global_position)
#el VALUE es el daño que recibio
#damage_numbers_origin.global_position = es solo el nodo donde va a mostrar el numero
#----------------------------


func _ready():
	Global.stats_updated.connect(enemy_update_stats)
	add_to_group("enemigos")
	enemy_update_stats()
	hp = max_hp
	health_bar.set_max_health(hp)
	
func _process(_delta):
	if not active:
		return
	if Global.player and is_instance_valid(Global.player):
		var dir = (Global.player.global_position - global_position).normalized()
		velocity = dir * speed
		ship.rotation = dir.angle() + deg_to_rad(90)
		move_and_slide()
		ship_sprite.show()
		health_bar.rotation = 0


func activate(pos: Vector2):
	global_position = pos
	hp = Global.enemigo_max_hp
	is_dead = false
	active = true
	show()
	set_process(true)
	health_bar.set_max_health(hp)
	ship_sprite.play("alive")
	propulsor.play("alive")



func take_damage(amount):
	if not active or is_dead:
		return
	hp -= amount
	health_bar.update_health(hp)
	ship_sprite.visible = false

	DamageNumbers.display_numbers(amount, damage_numbers_origin.global_position)
	DamageNumbers.flash_sprite(ship_sprite)
	if hp <= 0:
		is_dead = true
		Global.emit_signal("enemy_killed")
		propulsor.visible = false
		ship_sprite.play("die")

		
func deactivate():
	hp = Global.enemigo_max_hp
	health_bar.set_max_health(hp)
	active = false
	is_dead = true
	set_process(false)
	hide()
	# Inform player we're out of range (if needed)
	if Global.player:
		Global.player.remove_enemy(self)


func enemy_update_stats():
	speed = Global.enemigo_speed
	max_hp = Global.enemigo_max_hp
	




func _on_ship_animation_finished() -> void:
	if ship_sprite.animation == "die" and is_dead:
		deactivate()
