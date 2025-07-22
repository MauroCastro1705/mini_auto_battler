extends Node

signal enemy_killed
signal stats_updated



#player vars
var player:Node = null
var player_score:int = 0
var player_money:float = 50
var player_logros:int = 0

var xp:int = 0
var level:int = 1
var attack_speed := 1.5 # Cooldown in seconds (lower = faster)
var atk_range:float = 350
var mobs_killed:int = 0

#BULLET
var bullet_dmg:float = 8
var bullet_speed: float = 400

#enemigos
var enemigo_speed:float = 40.0
var enemigo_max_hp:float = 22.0
var enemigo_level:int = 1
var enemigo_score:int = 10
var enemigo_money:int = 5



func _ready() -> void:
	enemy_killed.connect(update_enemy_kills)
	
func update_enemy_kills():
	print("señal en global recibida")

func update_scores():
	player_money += enemigo_money
	player_score += enemigo_score
	print("SCORE: ", player_score, "  MONEY: ", player_money)


func upgrade_mob():
	enemigo_level += 1
	enemigo_speed += 5.0
	enemigo_max_hp += 12.0
	enemigo_money += 3
	enemigo_score += 2
