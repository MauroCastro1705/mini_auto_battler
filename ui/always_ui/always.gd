extends Control
@onready var level_label: Label = $BoxContainer/MarginContainer/HBoxContainer/level/VBoxContainer/Label2
@onready var money_label: Label = $BoxContainer/MarginContainer/HBoxContainer/player_money/VBoxContainer/Label2
func _ready():
	Global.stats_updated.connect(update_labels)
	# Register this UI as the coin/money target provider for enemies that don't have an explicit travel_position
	CoinScript.coin_target = self
	update_labels() # Initial display


func get_coin_target_global_position() -> Vector2:
	# Returns a world-space position where coins should travel to.
	# Converts the `money_label` Control global position into world coordinates.
	var control_pos: Vector2 = money_label.get_global_position()
	var canvas_xform = get_viewport().get_canvas_transform()
	if canvas_xform:
		return canvas_xform.xform_inv(control_pos)
	return control_pos
	
func update_labels() -> void:
	level_label.text = str(Global.level)
	money_label.text = str(Global.player_money," $")
