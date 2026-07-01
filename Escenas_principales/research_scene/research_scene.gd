extends Node2D
@onready var upgrade_text: Label = %upgrade_text
@onready var texture_cost: TextureRect = %texture_cost
@onready var label_cost: Label = %label_cost

#@export var upgrade_price:int = 0
#@export var mineral_cost:Texture2D
#@export var upgrade_name:String = ""
#@export var upgrade_text:String = ""

func update(boton_upgrade):
	upgrade_text.text = boton_upgrade.upgrade_text
	texture_cost.texture = boton_upgrade.mineral_cost
	label_cost.text = str(boton_upgrade.upgrade_price)

func _on_button_yes_pressed() -> void:
	pass # Replace with function body.


func _on_button_no_pressed() -> void:
	pass # Replace with function body.
