extends BoxContainer
@onready var stat_title: Label = %stat_title
@onready var stat_value: Label = %stat_value
@onready var precio: Label = %precio
@onready var stat_level_label: Label = %stat_level
@onready var buy_button: Button = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/Button

const MAX_LEVEL := 50             # opcional: cap duro de niveles
var stat_comprado:float = 1.0
var stat_cost:int = 50

var sps_growth := 1.0 # how much more per level
var stat_level:int = 1


func _ready() -> void:
	stat_title.text = "Bullet dmg"
	stat_value.text = "+ " + str(sps_growth) + "dmg"
	precio.text = str(stat_cost) + "$"
	stat_level_label.text = "Level: " + str(Global.bullet_dmg_level)

func _on_button_pressed() -> void:
	check_level()
	check_funds()
	
func check_funds():
	if Global.player_money >= stat_cost:
		upgrade_stat()
	else:
		print("no hay plata, fondos =  ", Global.player_money)

func upgrade_stat():
	Global.bullet_dmg = Global.bullet_dmg + sps_growth
	Global.player_money -= stat_cost
	stat_comprado += 0.02
	Global.bullet_dmg_level += 1
	update_price()
	Global.emit_signal("stats_updated")
	stat_level_label.text = "Level: " + str(Global.bullet_dmg_level)
	print("nuevo valor de attack_dmg: ", Global.bullet_dmg)
	
func update_price():
	stat_cost = round(stat_cost * stat_comprado)
	precio.text = str(stat_cost) + "$"
	stat_level_label.text = "Level: " + str(stat_level)

func check_level():
	if Global.bullet_dmg_level >= MAX_LEVEL:
		precio.text = "MAX"
		if is_instance_valid(buy_button):
			buy_button.disabled = true
			buy_button.text = "Max"
