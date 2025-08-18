extends CharacterBody2D

# Parámetros
var speed
var max_hp
var hp
var active := false
var is_dead := false

@onready var damage_numbers_origin: Node2D = $damage_numbers_origin
@onready var ship_sprite: AnimatedSprite2D = %ship
@onready var health_bar: Control = %HealthBar
@onready var ship: Node2D = $Node2D
@onready var propulsor: AnimatedSprite2D = %propulsor

# Guarda capas/máscaras originales para reponer al activar
var _orig_layer: int
var _orig_mask: int

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

	# Cachea capas originales
	_orig_layer = collision_layer
	_orig_mask = collision_mask

	# Arranca seguro por si el pool te instancia ya "muerto/inactivo"
	_set_colliders_disabled(true)
	set_physics_process(false)
	set_process(false)
	hide()

func _process(_delta):
	if not active:
		return
	if Global.planet and is_instance_valid(Global.planet):
		var dir = (Global.planet.global_position - global_position).normalized()
		velocity = dir * speed
		ship.rotation = dir.angle() + deg_to_rad(90)
		move_and_slide()
		ship_sprite.show()
		health_bar.rotation = 0

func activate(pos: Vector2):
	global_position = pos
	# Reactiva estado
	is_dead = false
	active = true
	hp = Global.enemigo_max_hp
	max_hp = Global.enemigo_max_hp
	health_bar.set_max_health(hp)
	health_bar.update_health(hp)

	# Reactiva colisiones/physics/visibilidad
	collision_layer = _orig_layer
	collision_mask = _orig_mask
	_set_colliders_disabled(false)
	show()
	set_process(true)
	set_physics_process(true)

	# Anims
	ship_sprite.play("alive")
	propulsor.play("alive")
	propulsor.visible = true

func take_damage(amount: int) -> void:
	if not active or is_dead:
		return

	hp -= amount
	health_bar.update_health(hp)

	DamageNumbers.display_numbers(amount, damage_numbers_origin.global_position)
	DamageNumbers.flash_sprite(ship_sprite)

	if hp <= 0:
		is_dead = true
		Global.emit_signal("enemy_killed")
		# Desactiva colisiones inmediatamente para que no bloquee
		_disable_collisions_now()
		# Reproduce anim de muerte (el sprite debe seguir visible para verla)
		ship_sprite.play("die")
		propulsor.visible = false

func deactivate():
	# Estado lógico
	active = false
	is_dead = true

	# Frena movimiento y procesa/physics
	velocity = Vector2.ZERO
	set_process(false)
	set_physics_process(false)

	# Desactiva colisiones y oculta
	_disable_collisions_now()
	hide()

	# Limpieza opcional con jugador
	if Global.player:
		Global.player.remove_enemy(self)

func enemy_update_stats():
	speed = Global.enemigo_speed
	max_hp = Global.enemigo_max_hp

func _on_ship_animation_finished() -> void:
	if ship_sprite.animation == "die" and is_dead:
		# Al terminar la anim de muerte, ocúltate/queda ya desactivado
		deactivate()

# -----------------------
# Helpers de colisiones
# -----------------------
func _disable_collisions_now():
	collision_layer = 0
	collision_mask = 0
	_set_colliders_disabled(true)

func _set_colliders_disabled(disabled: bool) -> void:
	# Deshabilita/rehabilita todos los CollisionShape2D dentro del enemigo (recursivo)
	_set_colliders_disabled_rec(self, disabled)

func _set_colliders_disabled_rec(node: Node, disabled: bool) -> void:
	if node is CollisionShape2D:
		(node as CollisionShape2D).disabled = disabled
	for c in node.get_children():
		_set_colliders_disabled_rec(c, disabled)
