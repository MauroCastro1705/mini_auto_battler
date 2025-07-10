extends CharacterBody2D
@onready var atk_timer: Timer = $atk_timer
@export var move_speed = 100
@export var attack_speed = 1.0
@export var damage = 10
@onready var bullet_pool: Node = $BulletPool
var enemies_in_range: Array[Node] = []

var shoot_cooldown := 0.8	
var time_since_shot := 0.0

func _process(delta):
	time_since_shot += delta
	if time_since_shot >= shoot_cooldown:
		shoot()
		time_since_shot = 0.0

func get_nearest_enemy() -> Node:
	var nearest = null
	var min_dist = INF
	for enemigos in enemies_in_range:
		if not is_instance_valid(enemigos):
			continue
		var dist = global_position.distance_squared_to(enemigos.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = enemigos
	return nearest



func shoot():
	var target = get_nearest_enemy()
	if target:
		var direction = (target.global_position - global_position).normalized()
		var bullet = bullet_pool.get_bullet()
		bullet.fire(global_position, direction)
		print("shooted")



func _on_enemy_detector_body_entered(body) -> void:
	if body.is_in_group("enemigos"):
		enemies_in_range.append(body)
		print("agregado",body)


func _on_enemy_detector_body_exited(body) -> void:
	enemies_in_range.erase(body)
