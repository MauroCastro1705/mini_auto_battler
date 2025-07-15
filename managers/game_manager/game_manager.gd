extends Node

var xp_to_next = 10

func _ready():
	Global.enemy_killed.connect(on_enemy_killed)

	

func on_enemy_killed():
	Global.xp += 1
	Global.mobs_killed += 1
	Global.update_scores()
	Global.emit_signal("stats_updated")
	if Global.xp >= xp_to_next:
		level_up()

func level_up():
	Global.level += 1
	Global.xp = 0
	
	xp_to_next += 5
	print("level up, nivel = ", Global.level)
	var base_sps := 1.0 # base shots per second
	var sps_growth := 0.05 # how much more per level
	var new_shots_per_sec := base_sps * sps_growth
	Global.attack_speed = 1.0 / new_shots_per_sec
	Global.emit_signal("stats_updated")

func _process(delta: float) -> void:
	check_conditions()
	
func check_conditions():
	if Global.mobs_killed == 2:
		show_logro("kill_5")
	elif Global.player_money >= 25:
		show_logro("collect_100_gold")

func show_logro(logro_id: String):
	var data = load("res://logros/data_logros/data_logros.gd")
	var logro = data.LOGROS.get(logro_id)
	if logro:
		var popup_scene = preload("res://logros/Logro_popUp.tscn").instantiate()
		get_tree().root.add_child(popup_scene)
		popup_scene.show_achievement(logro.title, logro.description)
	else:
		print("Logro no encontrado:", logro_id)

	
