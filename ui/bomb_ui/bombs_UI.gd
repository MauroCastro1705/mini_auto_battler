extends Control
@onready var bomb_amount: Label = %bomb_amount

func _ready() -> void:
	Global.bomb_droped.connect(update_ui)
	update_ui()
	
	
func  update_ui():
	bomb_amount.text = str(Global.player_bombs)
