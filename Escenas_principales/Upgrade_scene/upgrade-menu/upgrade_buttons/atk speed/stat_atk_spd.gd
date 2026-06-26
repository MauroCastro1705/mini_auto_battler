extends BoxContainer
@onready var stat_title: Label = %stat_title
@onready var stat_value: Label = %stat_value
@onready var precio: Label = %precio
@onready var stat_level_label: Label = %stat_level
@onready var buy_button: Button = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/Button


var stat_comprado:float = 1.0
var stat_cost:int = 50
var base_sps := 1.0 # base shots per second
var sps_growth := 0.05 # how much more per level
var stat_level:int = 1
# --- Estado ---
var level: int = 1
# --- Balance/config ---
const BASE_COOLDOWN := 1.0 / 0.7 # segundos por disparo base (1.0 -> 1 SPS base)
const MIN_COOLDOWN := 0.15        # seguridad: nunca menos de esto (≈6.66 SPS)
const BONUS_CAP := 0.60           # cap total de reducción de cooldown: 60%
const BONUS_K := 0.35             # rapidez para acercarse al cap (sube => mejoras fuertes al principio)

const BASE_COST := 25            # costo nivel 1
const COST_GROWTH := 1.20         # multiplicador por nivel (1.20 = +20% por nivel)

const MAX_LEVEL := 50             # opcional: cap duro de niveles


func _ready() -> void:
	stat_title.text = "Atk Speed"
	# Si ya tenés un valor persistido:
	if "atk_speed_level" in Global:
		level = max(1, Global.atk_speed_level)
	_apply_to_global()
	_update_ui()
	
func _on_button_pressed() -> void:
	_try_buy()

#NUEVOOOOO
# --------- Lógica de balance ----------
func _cooldown_for_level(l: int) -> float:
	# Curva asintótica: reduce el cooldown hasta BASE_COOLDOWN * (1 - BONUS_CAP)
	var bonus := BONUS_CAP * (1.0 - exp(-BONUS_K * float(l - 1)))
	var cd := BASE_COOLDOWN * (1.0 - bonus)
	return max(MIN_COOLDOWN, cd)

func _sps_for_level(l: int) -> float:
	return 1.0 / _cooldown_for_level(l)

func _cost_for_level(l: int) -> int:
	# Costo del nivel ACTUAL (pagar para pasar de l -> l+1)
	return int(round(BASE_COST * pow(COST_GROWTH, float(l - 1))))

# --------- Compra / Aplicación ----------
func _try_buy() -> void:
	if level >= MAX_LEVEL:
		print("Alcanzaste el nivel máximo de velocidad de ataque.")
		return
	var cost := _cost_for_level(level)
	if Global.player_money < cost:
		print("Fondos insuficientes. Tenés: ", Global.player_money, " / Necesitás: ", cost)
		return

	# Cobrar y subir nivel
	Global.player_money -= cost
	level += 1
	Global.atk_speed_level = level  # en global para persistir el valor
	_apply_to_global()
	Global.emit_signal("stats_updated")
	_update_ui()

func _apply_to_global() -> void:
	# Escribimos ambos: cooldown (para el Timer) y SPS (para mostrar/hud)
	Global.attack_cooldown = _cooldown_for_level(level)
	Global.attack_speed = _sps_for_level(level)

# --------- UI ----------
func _update_ui() -> void:
	var next_sps := _sps_for_level(min(level + 1, MAX_LEVEL))
	var cost := 0 if level >= MAX_LEVEL else _cost_for_level(level)

	# Mostrar "SPS actual → SPS siguiente" con 2 decimales
	stat_value.text = "%0.2f SPS" % [next_sps]
	stat_level_label.text = "Level: %d" % level

	if level >= MAX_LEVEL:
		precio.text = "MAX"
		if is_instance_valid(buy_button):
			buy_button.disabled = true
			buy_button.text = "Max"
	else:
		precio.text = str(cost) + "$"
		if is_instance_valid(buy_button):
			buy_button.disabled = Global.player_money < cost
			buy_button.text = "Comprar"
