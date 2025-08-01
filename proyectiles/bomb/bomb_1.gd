extends Node2D
var damage:int = 10
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	sprite.hide()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		explode()


func explode():
	sprite.show()
	sprite.play("explosion")


func _on_explosion_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		var impact_fx = preload("res://resources/impact_particle_new.tscn").instantiate()
		get_tree().current_scene.add_child(impact_fx)
		impact_fx.global_position = global_position
		impact_fx.emitting = true
		body.take_damage(damage)
		


func _on_animated_sprite_2d_animation_finished() -> void:
	sprite.hide()
