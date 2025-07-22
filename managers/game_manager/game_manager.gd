extends Node

@onready var upgrade_menu: Node2D = $"../CanvasLayer/Upgrade-menu"

@onready var logro_pop_up: Control = $"../CanvasLayer/LogroPopUp"
var logros_obtenidos := {}

func _ready():
	Global.enemy_killed.connect(on_enemy_killed)
	logro_pop_up.stop_pause.connect(stop_pause_manager)
	LogrosData.GameManager = self
	upgrade_menu.visible = true

func on_enemy_killed():
	Global.xp += 1
	Global.mobs_killed += 1
	Global.update_scores()
	Global.emit_signal("stats_updated")
	if Global.xp >= Global.xp_to_next:
		level_up()

func level_up():
	Global.level += 1
	Global.xp = 0
	Global.xp_to_next += 5
	print("level up, nivel = ", Global.level)
	Global.emit_signal("stats_updated")

func _process(_delta: float) -> void:
	LogrosData.check_conditions()
	

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
