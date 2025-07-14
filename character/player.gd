extends CharacterBody2D
@onready var atk_timer: Timer = $atk_timer
@onready var bullet_pool: Node = $BulletPool
var enemies_in_range: Array[Node] = []
@onready var atk_range = $enemy_detector/CollisionShape2D
var shoot_cooldown := 0.8
var time_since_shot := 0.0


func _ready():
	Global.player = self
	Global.stats_updated.connect(update_global)
	update_global() # Initial call

func update_global():
	shoot_cooldown = Global.attack_speed
	atk_range.shape.radius = Global.atk_range
	
func _process(delta):
	time_since_shot += delta
	var target = get_nearest_enemy()
	if target:
		look_at(target.global_position) 
	if time_since_shot >= shoot_cooldown:
		shoot()
		time_since_shot = 0.0

func get_nearest_enemy() -> Node:
	var nearest = null
	var min_dist = INF

	# Create a filtered list to remove inactive or freed enemies
	enemies_in_range = enemies_in_range.filter(func(enemy):
		return is_instance_valid(enemy) and enemy.active
	)

	for enemy in enemies_in_range:
		var dist = global_position.distance_squared_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = enemy

	return nearest

func remove_enemy(enemy: Node):
	enemies_in_range.erase(enemy)

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
