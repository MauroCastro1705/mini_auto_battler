extends Node

var GameManager
var logros_obtenidos := {}

func _ready() -> void:
	logros_obtenidos = {}
	
var LOGROS = {
	"kill_2": {
		"title": "¡Cazador inicial!",
		"description": "Has derrotado a 2 enemigos."
	},
	"collect_150_gold": {
		"title": "Forrado en oro",
		"description": "Has recolectado 150 monedas."
	},
	"first_boss": {
		"title": "¡Jefe vencido!",
		"description": "Has derrotado al primer jefe del juego."
	},
}





func check_conditions():
	if Global.mobs_killed >= 2 and "kill_2" not in logros_obtenidos:
		GameManager.show_logro("kill_2")
		logros_obtenidos["kill_2"] = true
	elif Global.player_money >= 150 and "collect_150_gold" not in logros_obtenidos:
		GameManager.show_logro("collect_150_gold")
		logros_obtenidos["collect_150_gold"] = true
