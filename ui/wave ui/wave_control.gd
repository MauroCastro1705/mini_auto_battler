extends Control

@export var wave_count := 5
@export var active_texture: Texture
@export var inactive_texture: Texture

@onready var slots := $HBoxContainer.get_children()


func _ready():
	Global.wave_advanced.connect(update_display)
	update_display() # Update immediately at load

func update_display():
	var wave = Global.current_wave
	for i in range(wave_count):
		slots[i].texture = active_texture if i == (wave - 1) % wave_count else inactive_texture
