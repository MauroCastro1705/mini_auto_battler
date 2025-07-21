extends Node

var xp_to_next = 10
@onready var logro_pop_up: Control = $"../CanvasLayer/LogroPopUp"
var logros_obtenidos := {}

func _ready():
	Global.enemy_killed.connect(on_enemy_killed)
	logro_pop_up.stop_pause.connect(stop_pause_manager)
	

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
	if Global.mobs_killed >= 2 and "kill_5" not in logros_obtenidos:
		show_logro("kill_5")
		logros_obtenidos["kill_5"] = true
	elif Global.player_money >= 25 and "collect_100_gold" not in logros_obtenidos:
		show_logro("collect_100_gold")
		logros_obtenidos["collect_100_gold"] = true



func show_logro(logro_id: String):
	var logro = LogrosData.LOGROS.get(logro_id)
	if logro:
		logro_pop_up.show_achievement(logro.title, logro.description)
		logro_pop_up.show()
		get_tree().paused = true
	else:
		print("Logro no encontrado:", logro_id)

	
func stop_pause_manager():
	get_tree().paused = false
	logro_pop_up.hide()
