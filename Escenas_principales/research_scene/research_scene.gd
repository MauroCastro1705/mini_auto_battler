extends Node2D

@onready var upgrade_text: Label = %upgrade_text
@onready var texture_cost: TextureRect = %texture_cost
@onready var label_cost: Label = %label_cost
@onready var error_msg: Label = %error_msg
@onready var research_timer: Timer = %research_timer
@onready var research_bar: ProgressBar = %research_bar
@onready var texture_progress_bar: TextureProgressBar = %TextureProgressBar

@export var research_visual_node: Node
@onready var res_text: Label = $VBoxContainer/current_research/HBoxContainer/res_text
@onready var spiner_animation: AnimatedSprite2D = $"VBoxContainer/current_research/spiner animation"

var reference_button
var stat_being_research
var research_finish: bool = false

func _ready() -> void:
	spiner_animation.hide()
	res_text.text = "Research aviable"
	error_msg.visible = false
	research_bar.visible = false  # Ocultar barra inicialmente
	texture_progress_bar.visible = false
	research_bar.min_value = 0.0
	research_bar.max_value = 1.0
	research_bar.value = 0.0

func _process(_delta: float) -> void:
	update_timer_bar()

## Actualiza la interfaz del upgrade con los datos del botón
## @param boton_upgrade: El nodo del botón de upgrade que contiene los datos
func update(boton_upgrade):
	upgrade_text.text = boton_upgrade.upgrade_text
	texture_cost.texture = boton_upgrade.mineral_cost
	label_cost.text = str(boton_upgrade.upgrade_price)
	store_reference(boton_upgrade)

func store_reference(value):
	reference_button = value
	
func _on_button_yes_pressed() -> void:
	if not has_enough_money(reference_button):
		show_error_message("No tienes suficiente dinero!", Color(1.0, 0.0, 0.0))
		return
	stat_buyer(reference_button)
	
func has_enough_money(data) -> bool:
	return Global.player_money >= data.upgrade_price

## Verifica si se tiene suficiente dinero y aplica la mejora
## @param boton_upgrade: Botón que contiene la estadística y costo a mejorar
func stat_buyer(boton_upgrade):
	# Restar el dinero primero (opcional: puedes hacerlo después de la investigación)
	Global.player_money -= boton_upgrade.upgrade_price
	
	# Aplicar la mejora según la estadística
	match boton_upgrade.stat_to_upgrade:
		boton_upgrade.STATS.MINE_DMG:
			Global.player_mine_damage += boton_upgrade.how_much_to_upgrade
			print("Se mejoró STAT MINE DMG")
			set_research_stat(boton_upgrade)
		boton_upgrade.STATS.CAN_AUTOMINE:
			if not Global.can_auto_mine:
				Global.can_auto_mine = true
			print("Se activó CAN_AUTOMINE")
			set_research_stat(boton_upgrade)  # Si quieres que tenga tiempo de investigación
		boton_upgrade.STATS.AUTO_MINE_DMG:
			Global.auto_mining_damage += boton_upgrade.how_much_to_upgrade
			print("Se mejoró STAT AUTO MINE DMG")
			set_research_stat(boton_upgrade)
		boton_upgrade.STATS.AUTO_MINE_TIMER:
			Global.auto_miner_timer -= boton_upgrade.how_much_to_upgrade
			print("Se mejoró STAT AUTO MINE TIMER")
			set_research_stat(boton_upgrade)
		_:
			print("Estadística no reconocida")
			return
	
	print("Dinero restante: ", Global.player_money)
	show_error_message("Comenzando Investigación", Color(0.0, 0.646, 0.237))
	Global.emit_signal("stats_updated")

func show_error_message(message: String, color: Color):
	error_msg.label_settings.font_color = color
	error_msg.text = message
	error_msg.visible = true
	
	# Crear timer para ocultar mensaje
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(func(): error_msg.visible = false)
	timer.start()

func set_research_stat(boton_upgrade):
	# Reiniciar estado de investigación
	spiner_animation.show()
	spiner_animation.play("default")
	res_text.text = "Researching..."
	research_finish = false
	stat_being_research = boton_upgrade.stat_to_upgrade
	
	# Configurar y mostrar la barra
	research_bar.visible = true
	texture_progress_bar.visible = true
	research_bar.value = 0.0  # Reiniciar barra a 0
	
	# Configurar el timer
	research_timer.wait_time = boton_upgrade.research_time
	research_timer.start()
	print("Timer iniciado: ", research_timer.wait_time, " segundos")
	print("Estadística en investigación: ", stat_being_research)
	
func update_timer_bar() -> void:
	# Solo actualizar si el timer está activo y la investigación no ha terminado
	if research_timer.is_stopped() or research_finish:
		return
	
	# Calcular el progreso (0 a 1)
	var progress: float = 1.0 - (research_timer.time_left / research_timer.wait_time)
	research_bar.value = clamp(progress, 0.0, 1.0)  # Asegurar que no se pase

func _on_research_timer_timeout() -> void:
	spiner_animation.hide()
	research_finish = true
	research_bar.visible = false  # Ocultar barra cuando termina
	res_text.text = "Research aviable"
	print("Investigación completada!")
	
	# Aquí puedes agregar lógica adicional cuando la investigación termina
	# Por ejemplo: aplicar efectos adicionales, mostrar mensaje, etc.
