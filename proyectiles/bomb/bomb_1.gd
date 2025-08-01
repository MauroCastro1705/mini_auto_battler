extends CharacterBody2D

var damage:int = 10
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_collision: CollisionShape2D = $explosion_area/CollisionShape2D
var speed:float = 400.0



func _ready() -> void:
	sprite.hide()
func get_input():
	var input_direction = Input.get_vector("izq", "der", "arriba", "abajo")
	velocity = input_direction * speed

func _physics_process(_delta):
	if Input.is_action_just_pressed("shoot"):
		explode()
	get_input()
	move_and_slide()
	

func explode():
	if Global.player_bombs < 1:
		print("no hay bombas disponibles")
		speed = 400
		return

	speed = 0
	set_bomb_params()
	sprite.show()
	sprite.play("explosion")
	Global.player_bombs -= 1
	Global.emit_signal("bomb_droped")

	# Apply damage to enemies in area
	var bodies = $explosion_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(damage)

func set_bomb_params():
	sprite.scale = Global.player_bomb_size
	sprite_collision.scale = Global.player_bomb_size
	damage = Global.player_bomb_dmg


func _on_animated_sprite_2d_animation_finished() -> void:
	sprite.hide()
	speed = 400
