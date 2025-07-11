extends Control
@onready var level_label: Label = $BoxContainer/HBoxContainer/level/VBoxContainer/Label2
@onready var exp_label: Label = $BoxContainer/HBoxContainer/exp/VBoxContainer/Label2
@onready var atk_speed_label: Label = $BoxContainer/HBoxContainer/atk_speed/VBoxContainer/Label2
@onready var atk_dmg_label: Label = $BoxContainer/HBoxContainer/atk_dmg/VBoxContainer/Label2
@onready var atk_range_label: Label = $BoxContainer/HBoxContainer/atk_range/VBoxContainer/Label2


func _process(delta: float) -> void:
	level_label.text = str(Global.level)
	exp_label.text = str(Global.xp)
	atk_speed_label.text = str(Global.level)
	atk_dmg_label.text = str(Global.level)
	atk_range_label.text = str(Global.level)
