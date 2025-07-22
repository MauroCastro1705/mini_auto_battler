extends BoxContainer

@onready var stat_title: Label = %stat_title
@onready var stat_value: Label = %stat_value
@onready var precio: Label = %precio
@onready var stat_level_label: Label = %stat_level
var stat_comprado:float = 1.0
var stat_cost:float = 35
var base_sps := 1.0 # base shots per second
var sps_growth := 0.5 # how much more per level
var stat_level:int = 1


func _ready() -> void:
	stat_title.text = "Atk Range"
	stat_value.text = "+ " + str(sps_growth)
	precio.text = str(stat_cost) + "$"
	stat_level_label.text = "Level: " + str(stat_level)

func _on_button_pressed() -> void:
	check_funds()
	
func check_funds():
	if Global.player_money >= stat_cost:
		upgrade_stat()
	else:
		print("no hay plata, fondos =  ", Global.player_money)

func upgrade_stat():
	Global.atk_range = Global.atk_range + log(1 + stat_level) * sps_growth
	Global.player_money -= stat_cost
	stat_comprado += 0.02
	stat_level += 1
	update_price()
	Global.emit_signal("stats_updated")
	print("nuevo valor de attack_range: ", Global.atk_range)
	
func update_price():
	stat_cost = stat_cost * stat_comprado
	precio.text = str(stat_cost) + "$"
	stat_level_label.text = "Level: " + str(stat_level)
