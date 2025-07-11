extends Control

@onready var mobs_killed: Label = $HBoxContainer/mobsKilled


func _ready():
	Global.enemy_killed.connect(on_enemy_killed)
	_update_text()
	
func on_enemy_killed():
	_update_text()

func _update_text():
	mobs_killed.text = str(Global.mobs_killed)
