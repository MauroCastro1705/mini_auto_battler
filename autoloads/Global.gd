extends Node

signal enemy_killed
signal stats_updated

#player vars
var player:Node = null

var xp:int = 0
var level:int = 1
var attack_speed := 1.5 # Cooldown in seconds (lower = faster)
var atk_range:float = 150


#BULLET
var bullet_dmg:int = 1
var bullet_speed: float = 400


#enemigos
var enemigo_speed:float = 55.0
var enemigo_max_hp:float = 3.0
