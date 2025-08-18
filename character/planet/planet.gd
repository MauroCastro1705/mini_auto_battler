extends Node2D

#sistema de dificultad
#var easy_enemigo_infiltrate_count:int = 5
#var normal_enemigo_infitrate_count:int = 3
#var hard_enemigo_infiltrate_count:int = 0
#var enemigos_infiltrados:int = 0

#este nodo solo detecta cuando los enemigos llegan a el, la logica esta en Global
func _ready() -> void:
	Global.planet = self


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemigos"):
		Global.emit_signal("enemigo_se_infiltro")
