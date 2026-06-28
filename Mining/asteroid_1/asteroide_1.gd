extends Node2D

@export var max_deposit: float = 200.0
@export var mineral_name: String = "minerals"
@export var mineral_value_per_unit: float = 1.0
@onready var deposit_label: Label = $HBoxContainer/mineral_label
@onready var texture_rect: TextureRect = $HBoxContainer/TextureRect
@onready var auto_miner_button: Button = $auto_miner_button
@onready var auto_miner_timer: Timer = %auto_miner

enum MINERALES { RECURSO_1, RECURSO_2 }
@export var mineral: MINERALES = MINERALES.RECURSO_1
@export var mineral_hardness: int = 1

var is_auto_mining: bool = false

var current_deposit: float = 0.0
var pos: Vector2 = Vector2.ZERO
var textures: Dictionary = {}

func _ready() -> void:
	auto_miner_button.show()
	textures = {
		MINERALES.RECURSO_1: load("res://assets/PNG/recurso_1.png"),
		MINERALES.RECURSO_2: load("res://assets/PNG/recurso_2.png"),
	}
	current_deposit = max_deposit
	update_display()
	texture_rect.texture = textures[mineral]

# Eliminamos _input global — cada botón maneja su propio input
# El boton de minar manual emite su propia señal (connected en el editor)

func _process(_delta: float) -> void:
	update_display()


func mine(amount: int, hardness: int) -> float:
	if current_deposit <= 0:
		update_display()
		return 0
	var mined_amount: int = min(amount, current_deposit) - hardness
	current_deposit -= mined_amount
	
	# Si se está auto-minando, los números aparecen en el centro del nodo
	# Si es click manual, aparecen donde clickeó el jugador
	var mine_pos: Vector2
	if is_auto_mining:
		mine_pos = get_global_transform_with_canvas().origin
	else:
		mine_pos = pos
	
	DamageNumbers.display_numbers_random(mined_amount, mine_pos)
	add_mineral_to_player(mined_amount)
	update_display()
	if current_deposit <= 0:
		current_deposit = 0
		update_display()
		queue_free()
	return mined_amount

func add_mineral_to_player(mined_amount: int) -> void:
	if mineral == MINERALES.RECURSO_1:
		Global.player_resource_1 += mined_amount
	elif mineral == MINERALES.RECURSO_2:
		Global.player_resource_2 += mined_amount
	Global.emit_signal("stats_updated")
	print("Mineral añadido al jugador: ", int(mined_amount), " de tipo: ", mineral)

func update_display() -> void:
	if not is_instance_valid(deposit_label):
		return
	deposit_label.text = "%d" % max(0.0, current_deposit)

func get_deposit_ratio() -> float:
	if max_deposit <= 0.0:
		return 0.0
	return current_deposit / max_deposit

func _on_button_pressed() -> void:
	pos = get_viewport().get_mouse_position()
	mine(Global.player_mine_damage, mineral_hardness)

func _on_auto_miner_button_pressed() -> void:
	is_auto_mining = true
	auto_miner_timer.start()

func _on_auto_miner_timeout() -> void:
	auto_mine()

func auto_mine():
	mine(Global.auto_mining_damage, mineral_hardness)
