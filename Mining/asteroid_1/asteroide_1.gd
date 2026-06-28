extends Node2D

# Usage:
# - Add this script to any mineable asteroid scene.
# - Set max_deposit to the total amount of mineral available.
# - Call mine(amount) from another script when the player mines this asteroid.
# - Use get_deposit_ratio() to read how much deposit remains (0.0 to 1.0).
# - The asteroid will disappear automatically when the deposit reaches zero.

@export var max_deposit: float = 200.0
@export var mineral_name: String = "minerals"
@export var mineral_value_per_unit: float = 1.0

@onready var deposit_label: Label = $HBoxContainer/mineral_label
@onready var texture_rect: TextureRect = $HBoxContainer/TextureRect


enum MINERALES { RECURSO_1, RECURSO_2 }
@export var mineral: MINERALES = MINERALES.RECURSO_1

@export var mineral_hardness: int = 1 # How much damage is required to mine this mineral (higher = harder)

var current_deposit: float = 0.0
var pos: Vector2 = Vector2.ZERO #para el mouse y el dedo touch

var textures: Dictionary = {}# Diccionario que mapea el enum a su textura

func _ready() -> void:
	textures = {
		MINERALES.RECURSO_1: load("res://assets/PNG/recurso_1.png"),
		MINERALES.RECURSO_2: load("res://assets/PNG/recurso_2.png"),
	}

	current_deposit = max_deposit
	update_display()
	texture_rect.texture = textures[mineral]

func _input(event: InputEvent) -> void:
	if event.is_pressed():        
		if event is InputEventMouseButton:
			pos = event.position
		elif event is InputEventScreenTouch:
			pos = event.position
		
		#if pos != Vector2.ZERO:
		#	print("Posición: ", pos)





func _process(_delta: float) -> void:
	update_display()


# Call this from your player or mining system.
# Returns how much mineral was actually removed.
func mine(amount: int, hardness: int) -> float:
	if current_deposit <= 0:
		update_display()
		return 0

	var mined_amount: int = min(amount, current_deposit) - hardness
	current_deposit -= mined_amount
	DamageNumbers.display_numbers_random(mined_amount, pos) #pos del mouse y touch
	add_mineral_to_player(mined_amount)
	update_display()


	if current_deposit <= 0:
		current_deposit = 0
		update_display()
		queue_free()

	return mined_amount

func add_mineral_to_player(mined_amount: int) -> void:
	if mineral  == MINERALES.RECURSO_1:
		Global.player_resource_1 += mined_amount
	elif mineral == MINERALES.RECURSO_2:
		Global.player_resource_2 += mined_amount
	Global.emit_signal("stats_updated") # Emitir señal para actualizar la UI del jugador
	print("Mineral añadido al jugador: ", int(mined_amount), " de tipo: ", mineral)



func update_display() -> void:
	if not is_instance_valid(deposit_label):
		return

	var remaining_value: float = float(max(0.0, current_deposit))
	deposit_label.text = "%d" % remaining_value

# Returns the remaining deposit as a percentage from 0.0 to 1.0.
func get_deposit_ratio() -> float:
	if max_deposit <= 0.0:
		return 0.0
	return current_deposit / max_deposit


func _on_button_pressed() -> void:
	mine(Global.player_mine_damage, mineral_hardness) # Use the global player mine damage value
	
func auto_mine():
	mine(Global.player_mine_damage, mineral_hardness)
	
