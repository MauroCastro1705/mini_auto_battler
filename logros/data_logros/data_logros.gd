extends Node

var GameManager
var logros_obtenidos := {}

func _ready() -> void:
	logros_obtenidos = {}
	
var LOGROS = {
	"kill_10": {
		"title": "¡Primeros 10!",
		"description": "Has derrotado a 10 enemigos."
	},
	"kill_20": {
		"title": "¡Primeros 20!",
		"description": "Has derrotado a 20 enemigos."
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
	if Global.mobs_killed_in_total >= 10 and "kill_10" not in logros_obtenidos:
		GameManager.show_logro("kill_10")
		logros_obtenidos["kill_10"] = true
	elif  Global.mobs_killed_in_total >= 20 and "kill_20" not in 		logros_obtenidos:
		GameManager.show_logro("kill_20")
		logros_obtenidos["kill_20"] = true
	elif Global.player_money >= 150 and "collect_150_gold" not in logros_obtenidos:
		GameManager.show_logro("collect_150_gold")
		logros_obtenidos["collect_150_gold"] = true
