extends Node2D
@onready var upgrade_text: Label = %upgrade_text
@onready var texture_cost: TextureRect = %texture_cost
@onready var label_cost: Label = %label_cost
var reference_button
var stat_being_research
#@export var upgrade_price:int = 0
#@export var mineral_cost:Texture2D
#@export var upgrade_name:String = ""
#@export var upgrade_text:String = ""
@onready var error_msg: Label = %error_msg
@onready var research_timer: Timer = %research_timer
@onready var research_bar: ProgressBar = %research_bar

func _ready() -> void:
	error_msg.visible = false

## Actualiza la interfaz del upgrade con los datos del botón
## @param boton_upgrade: El nodo del botón de upgrade que contiene los datos
func update(boton_upgrade):
	upgrade_text.text = boton_upgrade.upgrade_text
	texture_cost.texture = boton_upgrade.mineral_cost
	label_cost.text = str(boton_upgrade.upgrade_price)
	store_reference(boton_upgrade)

func store_reference(value):
	reference_button = value
	
func _on_button_yes_pressed() -> void:##para comprar la mejora
	if not has_enough_money(reference_button):
		show_error_message("No tienes suficiente dinero!", Color(1.0, 0.0, 0.0))
		return
	stat_buyer(reference_button)
	
func has_enough_money(data) -> bool:
	return Global.player_money >= data.upgrade_price
	

## Verifica si se tiene suficiente dinero y aplica la mejora
## @param boton_upgrade: Botón que contiene la estadística y costo a mejorar
func stat_buyer(boton_upgrade):	
	# Aplicar la mejora según la estadística
	match boton_upgrade.stat_to_upgrade:
		boton_upgrade.STATS.MINE_DMG:
			Global.player_mine_damage += boton_upgrade.how_much_to_upgrade
			print("Se mejoró STAT MINE DMG")
			set_research_stat(boton_upgrade.STATS.MINE_DMG)
		boton_upgrade.STATS.CAN_AUTOMINE:
			if not Global.can_auto_mine:# Si es la primera vez, activar; si no, quizás aumentar algo
				Global.can_auto_mine = true
			print("Se activó/minó CAN_AUTOMINE")
		boton_upgrade.STATS.AUTO_MINE_DMG:
			Global.auto_mining_damage += boton_upgrade.how_much_to_upgrade
			print("Se mejoró STAT AUTO MINE DMG")
		boton_upgrade.STATS.AUTO_MINE_TIMER:
			Global.auto_miner_timer -= boton_upgrade.how_much_to_upgrade #resta porque es timer
			print("Se mejoró STAT AUTO MINE TIMER")
		_:
			print("Estadística no reconocida")
			return
	
	# Restar el dinero después de comprar
	Global.player_money -= boton_upgrade.upgrade_price
	print("Dinero restante: ", Global.player_money)
	show_error_message("Comenzando Investigacion", Color(0.0, 0.646, 0.237))
	# Emitir señal de que las estadísticas se actualizaron
	Global.emit_signal("stats_updated")

func show_error_message(message: String, color:Color):
	error_msg.label_settings.font_color = color
	error_msg.text = message
	error_msg.visible = true
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(func(): error_msg.visible = false)
	timer.start()

func set_research_stat(stat):
	stat_being_research = stat
	print("stat = " , stat)
