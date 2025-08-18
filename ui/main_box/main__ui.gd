extends Control
@onready var stat_box: BoxContainer = $BoxContainer
@onready var button: Button = $Button
@onready var is_button_pressed:bool = false

@onready var exp_label: Label = $BoxContainer/MarginContainer/HBoxContainer/exp/VBoxContainer/xp_label
@onready var atk_speed_label: Label = $BoxContainer/MarginContainer/HBoxContainer/atk_speed/VBoxContainer/Label2
@onready var atk_dmg_label: Label = $BoxContainer/MarginContainer/HBoxContainer/atk_dmg/VBoxContainer/Label2
@onready var atk_range_label: Label = $BoxContainer/MarginContainer/HBoxContainer/atk_range/VBoxContainer/Label2
@onready var enemy_label: Label = $BoxContainer/MarginContainer/HBoxContainer/enemy_level/VBoxContainer/Label2
var start_position = Vector2(0, 1200)
var final_position = Vector2(0, 1100)#original 0, 770

func _ready():
	Global.stats_updated.connect(update_labels)
	update_labels() # Initial display
	stat_box.hide()
	button.text = "Show stats"
	
func update_labels() -> void:
	var shots_per_second = 1.0 / Global.attack_speed
	exp_label.text = str(Global.xp)
	atk_speed_label.text = str("%.1f" % shots_per_second)
	atk_dmg_label.text = str(Global.bullet_dmg)
	atk_range_label.text = str(int(round(Global.atk_range)))
	enemy_label.text = str(Global.enemigo_level)


func _on_button_pressed() -> void:
	if is_button_pressed == false:
		is_button_pressed = true
		button.text = "Hide stats"
		stat_box.show()
		print("escondo stats")

	else:
		is_button_pressed = false
		button.text = "Show stats"
		stat_box.hide()
		print("NO escondo stats")
