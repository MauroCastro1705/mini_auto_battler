extends Node2D
class_name Bullet

const ImpactFX := preload("res://resources/impact_particle_new.tscn")
const ENEMY_MASK := 1 << 1 # capa 2

@onready var area: Area2D = $Area2D
@onready var shape: CollisionShape2D = $Area2D/CollisionShape2D

var damage
var speed: float
var direction: Vector2 = Vector2.ZERO
var active := false
var lifetime := 2.0
var time_alive := 0.0

var _prev_pos: Vector2

func _ready() -> void:
	hide()
	damage = Global.bullet_dmg
	speed  = Global.bullet_speed
	Global.stats_updated.connect(update_values)

	# En pool: sin colisiones
	area.monitoring = false
	shape.disabled  = true

func update_values() -> void:
	damage = Global.bullet_dmg
	speed  = Global.bullet_speed

func fire(fire_position: Vector2, dir: Vector2) -> void:
	# 1) Posicionar y orientar primero
	global_position = fire_position
	_prev_pos = global_position
	direction = dir.normalized()
	rotation = direction.angle()

	# 2) Reset de vida/estado visual
	time_alive = 0.0
	active = true
	show()

	# 3) Habilitar colisiones de inmediato (importante para no “perder” el primer frame)
	# Si llamas fire() desde _physics_process, cambia estas dos líneas por set_deferred(...)
	shape.disabled  = false
	area.monitoring = true

func _physics_process(delta: float) -> void:
	if not active:
		return

	# Siguiente posición
	var next_pos := global_position + direction * speed * delta

	# Barrido anti-túnel
	var space := get_world_2d().direct_space_state
	var params := PhysicsRayQueryParameters2D.create(_prev_pos, next_pos)
	params.collide_with_bodies = true
	params.collide_with_areas  = false
	params.collision_mask      = ENEMY_MASK
	params.exclude             = [self]

	var hit := space.intersect_ray(params)
	if hit:
		var where: Vector2 = hit["position"]
		global_position = where

		var body = hit.get("collider")
		if body and body.has_method("take_damage"):
			body.take_damage(damage)

		_spawn_impact(where)
		deactivate()
		return

	# Sin impacto: avanza normal
	global_position = next_pos
	_prev_pos = global_position

	time_alive += delta
	if time_alive > lifetime:
		deactivate()

func deactivate() -> void:
	active = false
	hide()
	# Apaga colisiones para volver al pool
	area.monitoring = false
	shape.disabled  = true

func _spawn_impact(where: Vector2) -> void:
	var fx := ImpactFX.instantiate()
	get_tree().current_scene.add_child(fx)
	fx.global_position = where
	fx.emitting = true

# (Opcional) Si tienes la señal body_entered conectada, mantenla como respaldo:
func _on_Area2D_body_entered(body: Node2D) -> void:
	if not active:
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
		_spawn_impact(global_position)
		deactivate()
