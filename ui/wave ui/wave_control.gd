extends Control

@export var wave_count := 5
@export var active_texture: Texture
@export var inactive_texture: Texture
@onready var timer: Timer = $Timer

@onready var slots := $HBoxContainer.get_children()
@onready var label: Label = $Label


func _ready():
	Global.wave_advanced.connect(update_display)
	update_display() # Update immediately at load

func update_display():
	var wave = Global.current_wave
	wave_text_update()
	for i in range(wave_count):
		slots[i].texture = active_texture if i == (wave - 1) % wave_count else inactive_texture
		
func wave_text_update():
	label.text = "Wave:" + str(Global.current_wave)
	label.show()
	timer.start()

func _on_timer_timeout() -> void:
	label.hide()
