extends Control
@onready var stat_title: Label = %stat_title
@onready var stat_level: Label = %stat_level
@onready var stat_value: Label = %stat_value
@onready var stat_cost: Label = %precio

@export var titulo:String
@export var nivel:int
@export var precio:int
@export var valor_stat:int

func _ready() -> void:
	asign_values()

func asign_values():
	stat_title.text = titulo
	stat_level.text = str(nivel)
	stat_value.text = str(valor_stat)
	stat_cost.text = str(precio)
	

func _on_button_pressed() -> void:
	pass # Replace with function body.
