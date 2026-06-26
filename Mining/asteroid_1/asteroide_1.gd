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

var current_deposit: float = 0.0

func _ready() -> void:
	current_deposit = max_deposit
	update_display()

func _process(_delta: float) -> void:
	update_display()

# Call this from your player or mining system.
# Returns how much mineral was actually removed.
func mine(amount: float) -> float:
	if current_deposit <= 0.0:
		update_display()
		return 0.0

	var mined_amount: float = min(amount, current_deposit)
	current_deposit -= mined_amount
	update_display()

	if current_deposit <= 0.0:
		current_deposit = 0.0
		update_display()
		queue_free()

	return mined_amount

func update_display() -> void:
	if not is_instance_valid(deposit_label):
		return

	var remaining_value: int = int(max(0.0, current_deposit))
	deposit_label.text = "%d" % remaining_value

# Returns the remaining deposit as a percentage from 0.0 to 1.0.
func get_deposit_ratio() -> float:
	if max_deposit <= 0.0:
		return 0.0
	return current_deposit / max_deposit
