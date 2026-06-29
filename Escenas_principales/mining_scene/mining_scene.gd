extends Node2D
@onready var mining_damage: Label = %mining_damage

var auto_miner_activated:bool = false
@onready var mineral_label_1: Label = %mineral_label1
@onready var mineral_label_2: Label = %mineral_label2

@onready var asteroide_1: Node2D = $Asteroide1
@onready var asteroide_2: Node2D = $Asteroide2
@onready var asteroide_3: Node2D = $Asteroide3
@onready var sample_timer: Timer = $sample_timer

var _accum_mineral_1: float = 0.0
var _accum_mineral_2: float = 0.0
var _mps_1: float = 0.0  # minerals per second tipo 1
var _mps_2: float = 0.0  # minerals per second tipo 2

func _ready() -> void:
	# Conectar la señal mine_collected de cada asteroide
	for asteroid in [asteroide_1, asteroide_2, asteroide_3]:
		if is_instance_valid(asteroid) and asteroid.has_signal("mine_collected"):
			asteroid.mine_collected.connect(_on_mine_collected)

func _process(_delta: float) -> void:
	mining_damage.text = str(Global.player_mine_damage)
	mineral_label_1.text = "%.1f /s" % _mps_1
	mineral_label_2.text = "%.1f /s" % _mps_2

# Cada asteroide emite esta señal al minar: mine_collected(amount, tipo)
func _on_mine_collected(amount: float, mineral_type: int) -> void:
	if mineral_type == 0:   # MINERALES.RECURSO_1
		_accum_mineral_1 += amount
	elif mineral_type == 1: # MINERALES.RECURSO_2
		_accum_mineral_2 += amount

func _on_sample_timer_timeout() -> void:
	_mps_1 = _accum_mineral_1 / sample_timer.wait_time
	_mps_2 = _accum_mineral_2 / sample_timer.wait_time
	_accum_mineral_1 = 0.0
	_accum_mineral_2 = 0.0
