extends Node
var damage_label = preload("res://resources/damage_numbers.tres")


func display_numbers(value:float, position:Vector2):
	var number = Label.new()
	number.global_position = position
	number.text = str(value)
	number.z_index = 15
	# Duplicamos el estilo y lo modificamos
	var label_settings = damage_label.duplicate()
	
	# Ajuste del color según el daño
	if value == 0:
		label_settings.font_color = Color("#FFFFFF88")  # Blanco translúcido
	elif value < 10:
		label_settings.font_color = Color("lightgreen")
	elif value < 30:
		label_settings.font_color = Color("yellow")
	else:
		label_settings.font_color = Color("red")

	# Ajuste del tamaño de fuente según el daño
	var base_size = 25
	var size_multiplier = clamp(value / 50.0, 0.8, 2.0)
	label_settings.font_size = base_size * size_multiplier
	number.label_settings = label_settings
	
	call_deferred("add_child", number)
	await number.resized
	
	number.pivot_offset = Vector2(number.size / 2)
	var tween  = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "position:y", number.position.y - 24, 0.25
		).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:y", number.position.y, 0.5 
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		number, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	number.queue_free()

func flash_sprite(sprite: CanvasItem) -> void:
	if not sprite: return
	
	var tween = sprite.get_tree().create_tween()
	tween.set_loops(2)  # Titila dos veces (apagado y encendido)
	tween.set_parallel(false)  # Que sea secuencial
	tween.tween_property(sprite, "modulate:a", 0.0, 0.1)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
