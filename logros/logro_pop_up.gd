extends Control


@onready var tittle: Label = %tittle
@onready var description: Label = %description
@onready var icon: TextureRect = %icon
@onready var button: Button = $CanvasLayer/NinePatchRect/Button

const PAUSE_MODE_INHERIT := 0
const PAUSE_MODE_STOP := 1
const PAUSE_MODE_PROCESS := 2

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS 
	visible = false
	
func show_achievement(title: String, descripcion: String, icon_texture: Texture = null):
	tittle.text = title
	self.description.text = descripcion
	if icon_texture:
		icon.texture = icon_texture
	visible = true
	get_tree().paused = true

func close_popup():
	get_tree().paused = false
	print("queriendo cerrar")
	call_deferred("queue_free")

func _on_button_pressed() -> void:
	print("aprete boton")
	close_popup()




#IMPLEMENTACION
#var popup = preload("res://logros/Logro_popUp.tscn").instantiate()
#get_tree().root.add_child(popup)
#popup.show_achievement("Logro desbloqueado", "Mataste 100 enemigos", some_icon)


#func _on_timer_timeout() -> void:
#	show_achievement("Logro desbloqueado", "Mataste 100 enemigos")
