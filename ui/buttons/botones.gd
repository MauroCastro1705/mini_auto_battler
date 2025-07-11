extends Control




func _on_atkrange_pressed() -> void:
	Global.atk_range += 1.0
	Global.emit_signal("stats_updated")


func _on_atkspeed_pressed() -> void:
	var current_sps := 1.0 / Global.attack_speed
	current_sps += 0.5 # or whatever increment you want
	current_sps = clamp(current_sps, 0.1, 10.0) # optional safety clamp

	Global.attack_speed = 1.0 / current_sps
	Global.emit_signal("stats_updated")
