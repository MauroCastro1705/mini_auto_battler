extends Node2D
@onready var mining_damage: Label = %mining_damage
@onready var auto_miner: Timer = $auto_miner

var auto_miner_activated:bool = false

@onready var asteroide_1: Node2D = $Asteroide1
@onready var asteroide_2: Node2D = $Asteroide2
@onready var asteroide_3: Node2D = $Asteroide3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	mining_damage.text = str(Global.player_mine_damage)


func _on_auto_miner_timeout() -> void:
	asteroide_2.auto_mine()
	if auto_miner_activated:
		auto_miner.start()
	


func _on_button_pressed() -> void:
	auto_miner.start()
	auto_miner_activated = true
