extends Control

signal stop_pause
@onready var tittle: Label = %tittle
@onready var description: Label = %description
@onready var icon: TextureRect = %icon

func _ready():
	visible = false
	
func show_achievement(title: String, descripcion: String, icon_texture: Texture = null):
	tittle.text = title
	self.description.text = descripcion
	if icon_texture:
		icon.texture = icon_texture


func close_popup():
	emit_signal("stop_pause")

func _on_button_pressed() -> void:
	print("aprete boton")
	close_popup()




#IMPLEMENTACION
#var popup = preload("res://logros/Logro_popUp.tscn").instantiate()
#get_tree().root.add_child(popup)
#popup.show_achievement("Logro desbloqueado", "Mataste 100 enemigos", some_icon)


#func _on_timer_timeout() -> void:
#	show_achievement("Logro desbloqueado", "Mataste 100 enemigos")
