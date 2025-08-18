extends Control

@onready var btn: Button = %ShowStatsButton
@onready var wrapper = $VBoxContainer/StatsWrapper
@onready var content = $VBoxContainer/StatsWrapper/StatsBox

@export var start_expanded := true
@export var anim_time := 0.25

var _is_expanded := true
var _expanded_h := 0.0
var _tween: Tween

func _ready() -> void:
	# Para que el “slide” recorte el contenido
	wrapper.clip_contents = true

	# Espera un frame para que el layout calcule tamaños
	await get_tree().process_frame
	_expanded_h = _measure_expanded_height_now()

	_is_expanded = start_expanded
	_apply_state(_is_expanded, true)

	if not btn.pressed.is_connected(_on_toggle_pressed):
		btn.pressed.connect(_on_toggle_pressed)

func _on_toggle_pressed() -> void:
	animate_panel(!_is_expanded)

func animate_panel(expand: bool) -> void:
	_is_expanded = expand

	# Si vamos a expandir, medir la altura destino
	if expand:
		wrapper.custom_minimum_size.y = 0
		wrapper.visible = true
		await get_tree().process_frame
		_expanded_h = _measure_expanded_height_now()

	# Mata tween previo si existía
	if _tween and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	var to_h := (_expanded_h if expand else 0.0)

	# Asegura alpha inicial coherente
	if expand and wrapper.modulate.a < 1.0:
		wrapper.modulate.a = 0.0

	# Animamos altura y alpha en paralelo
	_tween.tween_property(wrapper, "custom_minimum_size:y", to_h, anim_time)
	_tween.parallel().tween_property(wrapper, "modulate:a", (1.0 if expand else 0.0), anim_time)

	_tween.finished.connect(func ():
		if expand:
			# Devuelve el control al layout normal
			wrapper.custom_minimum_size.y = 0
			wrapper.modulate.a = 1.0
			await get_tree().process_frame
			_expanded_h = _measure_expanded_height_now()
		else:
			# Oculta al final para que no reciba foco/tab
			wrapper.visible = false
			wrapper.modulate.a = 1.0
	)

	btn.text = ("Hide stats" if expand else "Show stats")

func _apply_state(expanded: bool, instant := false) -> void:
	if instant:
		if expanded:
			wrapper.visible = true
			wrapper.custom_minimum_size.y = 0
			wrapper.modulate.a = 1.0
			await get_tree().process_frame
			_expanded_h = _measure_expanded_height_now()
		else:
			wrapper.custom_minimum_size.y = 0
			wrapper.visible = false
			wrapper.modulate.a = 1.0
	else:
		animate_panel(expanded)

	btn.text = ("Hide stats" if expanded else "Show stats")
	_is_expanded = expanded

func _measure_expanded_height_now() -> float:
	if not wrapper.visible:
		wrapper.visible = true
	wrapper.custom_minimum_size.y = 0
	var natural = max(wrapper.size.y, content.get_combined_minimum_size().y)
	return natural
