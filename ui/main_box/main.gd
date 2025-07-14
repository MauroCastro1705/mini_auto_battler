extends Control
@onready var box_container: BoxContainer = $BoxContainer

@onready var exp_label: Label = $BoxContainer/MarginContainer/HBoxContainer/exp/VBoxContainer/xp_label
@onready var atk_speed_label: Label = $BoxContainer/MarginContainer/HBoxContainer/atk_speed/VBoxContainer/Label2
@onready var atk_dmg_label: Label = $BoxContainer/MarginContainer/HBoxContainer/atk_dmg/VBoxContainer/Label2
@onready var atk_range_label: Label = $BoxContainer/MarginContainer/HBoxContainer/atk_range/VBoxContainer/Label2
var shots_per_second = 1.0 / Global.attack_speed
@onready var enemy_label: Label = $BoxContainer/MarginContainer/HBoxContainer/enemy_level/VBoxContainer/Label2
var start_position = Vector2(0, 940)
var final_position = Vector2(0, 270)#original 0, 770


func _ready():
	Global.stats_updated.connect(update_labels)
	update_labels() # Initial display
	print("posicion ui: ", start_position)
	box_container.global_position = start_position
	
func update_labels() -> void:
	var shots_per_second = 1.0 / Global.attack_speed
	exp_label.text = str(Global.xp)
	atk_speed_label.text = str("%.1f" % shots_per_second)
	atk_dmg_label.text = str(Global.bullet_dmg)
	atk_range_label.text = str(int(round(Global.atk_range)))
	enemy_label.text = str(Global.enemigo_level)

func _on_control_mouse_entered() -> void:
	box_container.global_position = final_position
	print("moved up")


func _on_control_mouse_exited() -> void:
	box_container.global_position = start_position
	print("moved down")
