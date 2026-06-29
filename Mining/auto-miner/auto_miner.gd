extends Node2D

@export var orbit_radius: float = 100.0
@export var orbit_speed: float = 1.0
@export var center_node: Node2D = null
@export var face_center: bool = true  # Si el nodo debe mirar al centro
@export var can_move:float = false

var current_angle: float = 0.0

func _ready():
	if center_node == null:
		center_node = get_parent().get_node_or_null("Marker2D")
	current_angle = 0.0

func _process(delta: float):
	if can_move:
		if center_node == null:
			return
		
		current_angle += orbit_speed * delta
		
		# Posición orbital
		var offset = Vector2(cos(current_angle), sin(current_angle)) * orbit_radius
		global_position = center_node.global_position + offset
		
		# Orientación: mirar hacia el centro
		if face_center:
			look_at(center_node.global_position)
