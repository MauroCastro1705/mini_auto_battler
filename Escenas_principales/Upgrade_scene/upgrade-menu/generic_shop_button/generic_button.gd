@tool
extends BoxContainer
#GENERIC BUTTON
@export var tittle:String
@onready var stat_title: Label = %stat_title
@onready var vendido: ColorRect = $MarginContainer/vendido

@export var value:int
@onready var precio_label: Label = %precio
@onready var sprite: AnimatedSprite2D = %sprite
@export var skill_level:String

@onready var stat_level_label: Label = %stat_level

var stat_comprado:float = 1.0
var stat_cost:int = 35
var base_sps := 1.0 # base shots per second
var sps_growth := 0.5 # how much more per level
var stat_level:float = 1


func _ready() -> void:
	vendido.hide()
	stat_title.text = tittle
	precio_label.text = str(value) + "$"
	stat_level_label.text = "Level: " + str(skill_level)

func _on_button_pressed() -> void:
	check_funds()
	
func check_funds():
	if Global.player_money >= stat_cost:
		upgrade_stat()
		vendido.show()
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
	stat_cost = round(stat_cost * stat_comprado)
	precio_label.text = str(stat_cost) + "$"
	stat_level_label.text = "Level:" + str(stat_level)
