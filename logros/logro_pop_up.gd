extends Control

@onready var tittle: Label = $NinePatchRect/MarginContainer/VBoxContainer/tittle
@onready var icon: TextureRect = $NinePatchRect/MarginContainer/VBoxContainer/icon

@onready var description: Label = $NinePatchRect/MarginContainer/VBoxContainer/description
@onready var button: Button = $NinePatchRect/MarginContainer/VBoxContainer/Button

const PAUSE_MODE_INHERIT := 0
const PAUSE_MODE_STOP := 1
const PAUSE_MODE_PROCESS := 2

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS 

func show_achievement(title: String, description: String, icon_texture: Texture = null):
	tittle.text = title
	self.description.text = description
	if icon_texture:
		icon.texture = icon_texture
	visible = true
	get_tree().paused = true

func close_popup():
	visible = false
	get_tree().paused = false
	
func _on_button_pressed() -> void:
	close_popup()
	print("hice click")



#IMPLEMENTACION
#var popup = preload("res://logros/Logro_popUp.tscn").instantiate()
#get_tree().root.add_child(popup)
#popup.show_achievement("Logro desbloqueado", "Mataste 100 enemigos", some_icon)


func _on_timer_timeout() -> void:
	show_achievement("Logro desbloqueado", "Mataste 100 enemigos")
