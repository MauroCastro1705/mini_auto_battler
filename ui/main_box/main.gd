extends Control
@onready var level_label: Label = $BoxContainer/MarginContainer/HBoxContainer/level/VBoxContainer/Label2
@onready var exp_label: Label = $BoxContainer/MarginContainer/HBoxContainer/exp/VBoxContainer/xp_label
@onready var atk_speed_label: Label = $BoxContainer/MarginContainer/HBoxContainer/atk_speed/VBoxContainer/Label2
@onready var atk_dmg_label: Label = $BoxContainer/MarginContainer/HBoxContainer/atk_dmg/VBoxContainer/Label2
@onready var atk_range_label: Label = $BoxContainer/MarginContainer/HBoxContainer/atk_range/VBoxContainer/Label2
var shots_per_second = 1.0 / Global.attack_speed
@onready var enemy_label: Label = $BoxContainer/MarginContainer/HBoxContainer/enemy_level/VBoxContainer/Label2

func _ready():
	Global.stats_updated.connect(update_labels)
	update_labels() # Initial display


func update_labels() -> void:
	var shots_per_second = 1.0 / Global.attack_speed
	level_label.text = str(Global.level)
	exp_label.text = str(Global.xp)
	atk_speed_label.text = str("%.1f" % shots_per_second)
	atk_dmg_label.text = str(Global.bullet_dmg)
	atk_range_label.text = str(int(round(Global.atk_range)))
	enemy_label.text = str(Global.enemigo_level)
