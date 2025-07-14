extends Control
@onready var level_label: Label = $BoxContainer/MarginContainer/HBoxContainer/level/VBoxContainer/Label2
@onready var money_label: Label = $BoxContainer/MarginContainer/HBoxContainer/player_money/VBoxContainer/Label2
func _ready():
	Global.stats_updated.connect(update_labels)
	update_labels() # Initial display
	
func update_labels() -> void:
	level_label.text = str(Global.level)
	money_label.text = str(Global.player_money," $")
