extends Node

signal enemy_killed
signal stats_updated
signal bomb_droped
signal wave_advanced
signal level_advanced
signal enemigo_se_infiltro

#player unlocked scenes
var locked_scene:bool = false

#player vars
var player:Node = null
var planet
var player_score:int = 0
var player_money:int = 100

#recursos del player
var player_resource_1:int = 0
var player_resource_2:int = 0


var player_logros:int = 0
var player_bombs:int = 300
var player_bomb_dmg:int = 20
var player_bomb_size:= Vector2(1.25, 1.25)


##mining stats
var player_mine_damage:int = 3
var can_auto_mine:bool = false
var auto_mining_damage:int = 2
var auto_miner_timer:float = 5.0



var xp:int = 0
var level:int = 1
var xp_to_next:int = 10

var attack_speed := 1.5 # Cooldown in seconds (lower = faster)
#persistent level stats
var atk_speed_level:= 1
var atk_range_level:= 1
var bullet_dmg_level:= 1
var bullet_speed_level:= 1


var attack_cooldown:float = 0.7
var atk_range:float = 350
var mobs_killed:int = 0
var mobs_killed_in_total:int = 0
#Player bot stats (upgrade)
var bot_atk_cooldown:= 1.5
var bot_atk_range:float = 200



#BULLET
var bullet_dmg:float = 6
var bullet_speed: float = 400

#dificulty system:
var easy_mode:bool = false
var normal_mode:bool = true
var hard_mode:bool = false

#enemigos
var easy_enemigo_infiltrate_count:int = 5 #sistema de dificultad
var normal_enemigo_infiltrate_count:int = 3
var hard_enemigo_infiltrate_count:int = 0
var enemigos_infiltrados:int = 0

var enemigo_speed:float = 20.0
var enemigo_max_hp:float = 22.0
var enemigo_level:int = 1
var enemigo_score:int = 10
var enemigo_money:int = 10
var enemigo_resource_1_value:int = 1
var enemigo_resource_2_value:int = 1

# --- ENEMY SCALING ---
var base_enemigo_hp:float = 22.0
var base_enemigo_speed:float = 20.0
var base_enemigo_money:int = 10
var base_enemigo_score:int = 10




# --- WAVE SYSTEM ---
var current_wave:int = 1 # global wave counter (kept for UI compatibility)

# Level system
var current_level:int = 1
var max_levels:int = 10
var waves_per_level:int = 5
var current_wave_in_level:int = 1

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
	enemigo_se_infiltro.connect(check_infiltrados)
	emit_signal("stats_updated")
	emit_signal("bomb_droped")
	

func update_scores():
	# Kept for compatibility: do not modify money/score here to avoid double-counting.
	# Score and money are updated by `update_enemy_kills()` and coin arrival respectively.
	print("SCORE: ", player_score, "  MONEY: ", player_money)

func get_enemies_per_wave() -> int:
	# Prefer explicit overrides per global wave index if present
	if wave_enemy_count.has(current_wave):
		return wave_enemy_count[current_wave]
	# Boss waves are usually single tough enemy
	if is_boss_wave:
		return 1
	# Base formula: scales with level and wave within level
	var base = 5
	var level_scale = (current_level - 1) * 3
	var wave_scale = (current_wave_in_level - 1) * 2
	return base + level_scale + wave_scale
		
func update_enemy_kills():#update de valors del player dinero y score
	mobs_killed += 1
	mobs_killed_in_total += 1
	player_score += enemigo_score

	if mobs_killed >= get_enemies_per_wave():
		# advance wave within level or progress to next level
		next_wave()
		print("Next Wave: ", current_wave, " (Level:", current_level, " WaveInLevel:", current_wave_in_level, ")")
	
func next_wave():
	mobs_killed = 0
	current_wave += 1
	current_wave_in_level += 1
	
	if current_wave_in_level > waves_per_level:
		start_next_level()
		return

	enemigos_infiltrados = 0
	emit_signal("wave_advanced")
	# update boss flag for the new wave
	is_boss_wave = current_wave % (max_wave_before_boss + 1) == 0
	scale_enemy_stats()
	
	#emigos se hacen mas poderos al avanzar las oleadas
func scale_enemy_stats():
	# Use global wave as aggregate difficulty driver to keep existing behaviour,
	# but add level influence as multiplier
	var scale_factor = current_wave
	var level_multiplier = 1.0 + (current_level - 1) * 0.15

	enemigo_max_hp = base_enemigo_hp + scale_factor * 3.0 * level_multiplier
	enemigo_speed = base_enemigo_speed + scale_factor * 1.1 * level_multiplier
	enemigo_money = base_enemigo_money + int(scale_factor * 1.2 * level_multiplier)
	enemigo_score = base_enemigo_score + int(scale_factor * 2 * level_multiplier)

	# Ensure integers where appropriate
	enemigo_money = max(1, enemigo_money)
	enemigo_score = max(1, enemigo_score)

	# update boss flag too
	is_boss_wave = current_wave % (max_wave_before_boss + 1) == 0


func start_next_level():
	if current_level >= max_levels:
		print("All levels completed or max level reached")
		return
	current_level += 1
	current_wave_in_level = 1
	# set global wave to the next wave index (keeps continuity)
	# optional: you may want to reset global wave count instead
	# keep enemies counters clean
	mobs_killed = 0
	enemigos_infiltrados = 0
	emit_signal("level_advanced")
	if mobs_killed >= get_enemies_per_wave():
		next_wave()
		print("Next Wave: ", current_wave, " (Level:", current_level, " WaveInLevel:", current_wave_in_level, ")")
	# helper to recompute or reset any level-scoped vars
	# Keep current_wave as-is to preserve UI that displays global wave
	return

func dificultad() -> String: # "danger level"
	if easy_mode:
		return "easy"
	elif normal_mode:
		return "normal"
	elif hard_mode:
		return "hard"
	else:
		return ""
		
#game over checks
func check_infiltrados():
	print("--------enemigo llego------")
	enemigos_infiltrados += 1
	if normal_mode and enemigos_infiltrados == normal_enemigo_infiltrate_count:
		print("game over")
	if easy_mode and enemigos_infiltrados == easy_enemigo_infiltrate_count:
		print("game over")
	if hard_mode and enemigos_infiltrados == hard_enemigo_infiltrate_count:
		print("game over")
