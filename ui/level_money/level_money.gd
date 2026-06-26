extends Control


@onready var resourse_1: Label = %resourse_1
@onready var resourse_2: Label = %resourse_2
@onready var coin_texture: TextureRect = %Coin_texture
@onready var level_label: Label = %level
@onready var money_label: Label = %money
@onready var resource_1_texture: TextureRect = %resource_1_texture
@onready var resource_2_texture: TextureRect = %resource_2_texture



func _ready():
	Global.stats_updated.connect(update_labels)
	# Register this UI as the coin/money target provider for enemies that don't have an explicit travel_position
	CoinScript.coin_target = self
	update_labels() # Initial display


func get_coin_target_global_position() -> Vector2:
	# Returns a world-space position where coins should travel to.
	# Converts the `money_label` Control global position into world coordinates.
	var control_pos: Vector2 = coin_texture.get_global_position()
	var center_offset: Vector2 = Vector2.ZERO
	if coin_texture:
		if coin_texture.has_method("get_size"):
			center_offset = coin_texture.get_size() * 0.5
		elif coin_texture.texture:
			center_offset = coin_texture.texture.get_size() * 0.5
	var center_pos: Vector2 = control_pos + center_offset
	var canvas_xform = get_viewport().get_canvas_transform()
	if canvas_xform:
		return canvas_xform.xform_inv(center_pos)
	return center_pos
	
func get_resourse1_target_global_position() -> Vector2:
	# Returns a world-space position where coins should travel to.
	var control_pos: Vector2 = resource_1_texture.get_global_position()
	var center_offset: Vector2 = Vector2.ZERO
	if resource_1_texture:
		if resource_1_texture.has_method("get_size"):
			center_offset = resource_1_texture.get_size() * 0.5
		elif resource_1_texture.texture:
			center_offset = resource_1_texture.texture.get_size() * 0.5
	var center_pos: Vector2 = control_pos + center_offset
	var canvas_xform = get_viewport().get_canvas_transform()
	if canvas_xform:
		return canvas_xform.xform_inv(center_pos)
	return center_pos
	
func get_resourse2_target_global_position() -> Vector2:
	# Returns a world-space position where coins should travel to.
	var control_pos: Vector2 = resource_2_texture.get_global_position()
	var center_offset: Vector2 = Vector2.ZERO
	if resource_2_texture:
		if resource_2_texture.has_method("get_size"):
			center_offset = resource_2_texture.get_size() * 0.5
		elif resource_2_texture.texture:
			center_offset = resource_2_texture.texture.get_size() * 0.5
	var center_pos: Vector2 = control_pos + center_offset
	var canvas_xform = get_viewport().get_canvas_transform()
	if canvas_xform:
		return canvas_xform.xform_inv(center_pos)
	return center_pos
	
func update_labels() -> void:
	level_label.text = str(Global.level)
	money_label.text = str(Global.player_money)
	resourse_1.text = str(Global.player_resource_1)
	resourse_2.text = str(Global.player_resource_2)
