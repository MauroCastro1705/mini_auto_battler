extends Control
@onready var damage_bar: ProgressBar = $HealthBarContainer/DamageBar
@onready var life_bar: ProgressBar = $HealthBarContainer/HealthBar
var max_health := 100
var current_health := 100
var damage_lerp_speed := 50.0  # velocidad en la que se reduce el daño visible

func set_max_health(value: int):
	max_health = value
	current_health = value
	life_bar.max_value = value
	damage_bar.max_value = value
	life_bar.value = value
	damage_bar.value = value

func update_health(new_value: int):
	current_health = clamp(new_value, 0, max_health)
	life_bar.value = current_health
	# El damage_bar se reduce con delay en _process

func _process(delta):
	if damage_bar.value > life_bar.value:
		damage_bar.value = max(damage_bar.value - damage_lerp_speed * delta, life_bar.value)
