extends Control
@onready var stat_box: BoxContainer = $BoxContainer
@onready var button: Button = $Button
@onready var is_button_pressed:bool = false

# 1st row
@onready var exp_label: Label = %xp_label
@onready var atk_speed_label: Label = %atk_speed
@onready var atk_dmg_label: Label = %dmg
@onready var atk_range_label: Label = %range
@onready var enemy_lvl_label: Label = %enemy_lvl

# 2nd row
@onready var wave_num_label: Label = %wave_num
@onready var dificulty_label: Label = %dificulty
@onready var enemis_left_label: Label = %enemis_left


func _ready():
	Global.stats_updated.connect(update_labels)
	update_labels() # Initial display
	stat_box.hide()
	button.text = "Show stats"
	
func update_labels() -> void:
	exp_label.text = str(Global.xp)
	atk_speed_label.text = "%.1f" % Global.attack_speed
	atk_dmg_label.text = str(Global.bullet_dmg)
	atk_range_label.text = str(int(round(Global.atk_range)))
	enemy_lvl_label.text = str(Global.enemigo_level)
	wave_num_label.text = str(Global.current_wave)
	dificulty_label.text = Global.dificultad()
	enemis_left_label.text = str(Global.get_enemies_per_wave())
	
func _on_button_pressed() -> void:
	if is_button_pressed == false:
		is_button_pressed = true
		button.text = "Hide stats"
		stat_box.show()

	else:
		is_button_pressed = false
		button.text = "Show stats"
		stat_box.hide()
