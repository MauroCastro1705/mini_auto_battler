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

	# Cachea capas/máscaras "buenas" (tu enemigo está en capa 2)
	_orig_layer = collision_layer
	_orig_mask  = collision_mask
	if _orig_layer == 0 and _orig_mask == 0:
		_orig_layer = 1 << 1   # capa 2
		_orig_mask  = 1 << 1   # máscara 2
	# Arranca seguro: sin colisión ni proceso
	_set_shapes_disabled_deferred(true)
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	set_process(false)
	set_physics_process(false)
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
	# Estado lógico y vida
	is_dead = false
	active  = true
	max_hp  = Global.enemigo_max_hp
	hp      = max(1, Global.enemigo_max_hp)   # clamp defensivo
	health_bar.set_max_health(hp)
	health_bar.update_health(hp)

	# 1) POSICIONAR PRIMERO
	global_position = pos

	# 2) MOSTRAR y procesar, pero SIN colisión este frame
	show()
	set_process(true)
	set_physics_process(true)
	_set_shapes_disabled_deferred(true)
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)

	# 3) HABILITAR COLISIONES EN EL SIGUIENTE FRAME
	call_deferred("_enable_collisions_next_frame")

	# Anims
	ship_sprite.play("alive")
	propulsor.visible = true
	propulsor.play("alive")

func _enable_collisions_next_frame() -> void:
	_set_shapes_disabled_deferred(false)
	set_deferred("collision_layer", _orig_layer)
	set_deferred("collision_mask",  _orig_mask)

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
		ship_sprite.play("die")
		propulsor.visible = false
		# DESACTIVAR EN DIFERIDO (evita flushing queries)
		call_deferred("_disable_collisions_now")
		
func deactivate():
	# Estado lógico
	active = false
	is_dead = true

	# Frena movimiento y procesa/physics
	velocity = Vector2.ZERO
	set_process(false)
	set_physics_process(false)

	# Desactiva colisiones y oculta
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	_disable_shapes_deferred(self, true)
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
func _disable_collisions_now() -> void:
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	_set_shapes_disabled_deferred(true)

func _set_shapes_disabled_deferred(disabled: bool) -> void:
	_shapes_set_disabled_rec(self, disabled)

func _shapes_set_disabled_rec(node: Node, disabled: bool) -> void:
	if node is CollisionShape2D:
		(node as CollisionShape2D).set_deferred("disabled", disabled)
	for c in node.get_children():
		_shapes_set_disabled_rec(c, disabled)
		
func _disable_shapes_deferred(node: Node, disabled: bool) -> void:
	if node is CollisionShape2D:
		(node as CollisionShape2D).set_deferred("disabled", disabled)
	for c in node.get_children():
		_disable_shapes_deferred(c, disabled)
		
func _set_colliders_disabled(disabled: bool) -> void:
	# Deshabilita/rehabilita todos los CollisionShape2D dentro del enemigo (recursivo)
	_set_colliders_disabled_rec(self, disabled)

func _set_colliders_disabled_rec(node: Node, disabled: bool) -> void:
	if node is CollisionShape2D:
		(node as CollisionShape2D).disabled = disabled
	for c in node.get_children():
		_set_colliders_disabled_rec(c, disabled)
