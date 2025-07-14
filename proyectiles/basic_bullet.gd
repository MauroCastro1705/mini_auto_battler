extends Node2D
class_name Bullet
@onready var damage = Global.bullet_dmg
@onready var speed = Global.bullet_speed
var direction: Vector2
var active := false
var lifetime := 2.0
var time_alive := 0.0

func _ready():
	hide()
	

func fire(fire_position: Vector2, dir: Vector2):
	global_position = fire_position
	direction = dir.normalized()
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


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		var impact_fx = preload("res://resources/impact_particle_new.tscn").instantiate()
		get_tree().current_scene.add_child(impact_fx)
		impact_fx.global_position = global_position
		impact_fx.emitting = true
		body.take_damage(damage)
		deactivate()
