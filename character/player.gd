extends CharacterBody2D
@onready var atk_timer: Timer = $atk_timer
@export var move_speed = 100
@export var attack_speed = 1.0
@export var bullet_scene: PackedScene
@export var damage = 10

var attack_timer := 0.0

func _process(delta):
	attack_timer += delta
	if attack_timer >= attack_speed:
		attack()
		attack_timer = 0.0

func attack():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = Vector2.RIGHT.rotated(randf_range(-PI/6, PI/6)) # Spread
	bullet.damage = damage
	get_tree().current_scene.add_child(bullet)
