extends Node

signal enemy_killed
signal stats_updated



#player vars
var player:Node = null
var player_score:int = 0
var player_money:int = 100
var player_logros:int = 0

var xp:int = 0
var level:int = 1
var xp_to_next:int = 10
var attack_speed := 1.5 # Cooldown in seconds (lower = faster)
var atk_range:float = 350
var mobs_killed:int = 0

#BULLET
var bullet_dmg:float = 8
var bullet_speed: float = 400

#enemigos
var enemigo_speed:float = 20.0
var enemigo_max_hp:float = 22.0
var enemigo_level:int = 1
var enemigo_score:int = 10
var enemigo_money:int = 5



func _ready() -> void:
	enemy_killed.connect(update_enemy_kills)
	
func update_enemy_kills():
	var base_sps := 0.2
	var sps_growth := 0.5
	var upgrade_stat = base_sps + log(1 + mobs_killed) * sps_growth
	print("upgrade stat es ", upgrade_stat)
	enemigo_max_hp = round(enemigo_max_hp + upgrade_stat) 
	enemigo_score = round(enemigo_score + upgrade_stat)
	enemigo_money = round(enemigo_money + upgrade_stat ) 
	print("enemigo_max_hp ", enemigo_max_hp )
	print("enemigo_score  ", enemigo_score )
	print("enemigo_money ", enemigo_money )
	

func update_scores():
	player_money += enemigo_money
	player_score += enemigo_score
	print("SCORE: ", player_score, "  MONEY: ", player_money)
