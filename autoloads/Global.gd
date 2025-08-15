extends Node

signal enemy_killed
signal stats_updated
signal bomb_droped
signal wave_advanced

#player vars
var player:Node = null
var player_score:int = 0
var player_money:int = 100
var player_logros:int = 0
var player_bombs:int = 300
var player_bomb_dmg:int = 20
var player_bomb_size:= Vector2(1.25, 1.25)

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
var easy_enemigo_infiltrate_count:int = 5 #sistema de dificultad
var normal_enemigo_infitrate_count:int = 3
var hard_enemigo_infiltrate_count:int = 0
var enemigos_infiltrados:int = 0

var enemigo_speed:float = 20.0
var enemigo_max_hp:float = 22.0
var enemigo_level:int = 1
var enemigo_score:int = 10
var enemigo_money:int = 10
# --- ENEMY SCALING ---
var base_enemigo_hp:float = 22.0
var base_enemigo_speed:float = 20.0
var base_enemigo_money:int = 10
var base_enemigo_score:int = 10




# --- WAVE SYSTEM ---
var current_wave:int = 1
var max_wave_before_boss:int = 5
var is_boss_wave:bool = false
var wave_enemy_count := {
	1: 2,
	2: 2,
	3: 2,
	4: 30,
	5: 37,
	6: 1, # Boss wave
	7: 6,
	8: 7,
	9: 8,
	10: 9,
	11: 1, # Boss again
}

func _ready() -> void:
	enemy_killed.connect(update_enemy_kills)
	emit_signal("stats_updated")
	emit_signal("bomb_droped")
	

func update_scores():
	player_money += enemigo_money
	player_score += enemigo_score
	print("SCORE: ", player_score, "  MONEY: ", player_money)

func get_enemies_per_wave() -> int:
	if wave_enemy_count.has(current_wave):
		return wave_enemy_count[current_wave]
	else:
		return 1 if is_boss_wave else 5 + current_wave * 2
		
func update_enemy_kills():#update de valors del player dinero y score
	mobs_killed += 1
	player_money += enemigo_money
	player_score += enemigo_score

	if mobs_killed >= get_enemies_per_wave():
		#se avanza de wave
		next_wave()
		is_boss_wave = current_wave % (max_wave_before_boss + 1) == 0
		print("Next Wave: ", current_wave)
	
func next_wave():
	mobs_killed = 0
	current_wave += 1
	enemigos_infiltrados = 0
	emit_signal("wave_advanced")
	scale_enemy_stats()
	
	#emigos se hacen mas poderos al avanzar las oleadas
func scale_enemy_stats():
	var scale_factor = current_wave

	enemigo_max_hp = base_enemigo_hp + scale_factor * 3.0
	enemigo_speed = base_enemigo_speed + scale_factor * 1.1
	enemigo_money = base_enemigo_money + scale_factor * 2
	enemigo_score = base_enemigo_score + scale_factor * 2
