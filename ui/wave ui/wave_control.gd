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
	# Keep textures active for waves that have passed.
	# Completed waves = current wave index - 1
	var completed = Global.current_wave - 1
	# If we've completed at least one full cycle, show all active
	if completed >= wave_count:
		for i in range(wave_count):
			slots[i].texture = active_texture
		return

	# Otherwise activate slots up to the current index
	var idx = (wave - 1) % wave_count
	for i in range(wave_count):
		slots[i].texture = active_texture if i <= idx else inactive_texture
		
func wave_text_update():
	label.text = "Wave:" + str(Global.current_wave)
	label.show()
	timer.start()

func _on_timer_timeout() -> void:
	label.hide()
