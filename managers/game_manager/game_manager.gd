extends Node

var xp_to_next = 10

func _ready():
	Global.enemy_killed.connect(on_enemy_killed)

func on_enemy_killed():
	Global.xp += 1
	Global.emit_signal("stats_updated")
	Global.mobs_killed += 1
	Global.update_scores()
	if Global.xp >= xp_to_next:
		level_up()

func level_up():
	Global.level += 1
	Global.xp = 0
	
	xp_to_next += 5
	print("level up, nivel = ", Global.level)
	var base_sps := 1.0 # base shots per second
	var sps_growth := 0.10 # how much more per level

	var new_shots_per_sec := base_sps + Global.level * sps_growth
	Global.attack_speed = 1.0 / new_shots_per_sec
	Global.emit_signal("stats_updated")
	
func popup():
	var popup = preload("res://logros/Logro_popUp.tscn").instantiate()
	get_tree().root.add_child(popup)
	popup.show_achievement("Logro desbloqueado", "Mataste 100 enemigos")
	
	
	
	
	
	


func _on_timer_timeout() -> void:
	popup()
