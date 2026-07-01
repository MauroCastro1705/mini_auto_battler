extends Control

@export var upgrade_price:int = 0
@export var mineral: MINERALES = MINERALES.RECURSO_1
var mineral_cost:Texture2D
@export var upgrade_name:String = ""
@export var upgrade_text:String = ""
@export var upgrade_icon:Texture2D
@export var nodo_padre:Node2D
var textures: Dictionary = {}
enum MINERALES { RECURSO_1, RECURSO_2 }
@export var stat_to_upgrade: STATS
enum STATS { MINE_DMG, CAN_AUTOMINE, AUTO_MINE_DMG, AUTO_MINE_TIMER }

#var player_mine_damage:int = 3
#var can_auto_mine:bool = false
#var auto_mining_damage:int = 2
#var auto_miner_timer:float = 5.0

@onready var icon_texture: TextureRect = %icon_texture
@onready var upgrade_name_local: Label = %upgrade_name

func _ready() -> void:
	textures = {
		MINERALES.RECURSO_1: load("res://assets/PNG/recurso_1.png"),
		MINERALES.RECURSO_2: load("res://assets/PNG/recurso_2.png"),
	}
	icon_texture.texture = upgrade_icon
	upgrade_name_local.text = upgrade_name
	mineral_cost = textures[mineral]


func _on_button_pressed() -> void:
	nodo_padre.update(self)
