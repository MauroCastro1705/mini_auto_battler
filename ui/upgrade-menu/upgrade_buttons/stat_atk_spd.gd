extends BoxContainer
@onready var stat_title: Label = %stat_title
@onready var stat_value: Label = %stat_value
@onready var precio: Label = %precio
var stat_comprado:float = 0.0
var stat_cost:int = 50
var stat_value_upgrade:int = 3


func _ready() -> void:
	stat_title.text = "Atk Speed"
	stat_value.text = "+ " + str(stat_value_upgrade)
	precio.text = str(stat_cost) + "$"

func update_price():
	stat_cost = stat_cost * stat_comprado
	precio.text = str(stat_cost) + "$"
	
func check_funds():
	if Global.player_money >= stat_cost:
		Global.attack_speed += stat_value_upgrade
		Global.player_money -= stat_cost
		print("nuevo valor ", Global.attack_speed)
		stat_comprado += 0.2
		update_price()
	else:
		print("no hay plata, fondos =  ", Global.player_money)

func _on_button_pressed() -> void:
	check_funds()
