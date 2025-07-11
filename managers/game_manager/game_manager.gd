extends Node

var xp_to_next = 10

func _ready():
	Global.enemy_killed.connect(on_enemy_killed)

func on_enemy_killed():
	Global.xp += 1
	if Global.xp >= xp_to_next:
		level_up()

func level_up():
	Global.level += 1
	Global.xp = 0
	xp_to_next += 5
	print("level up, nivel = ", Global.level)
	#$UpgradeMenu.show_random_upgrades()
