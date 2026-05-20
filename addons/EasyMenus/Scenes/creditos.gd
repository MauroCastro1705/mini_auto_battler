extends Node2D

@onready var sonido_boton: AudioStreamPlayer2D = $sonido_boton

func _ready() -> void:
	pass
	
func _on_button_pressed() -> void:
	SceneChanger.change_scene_with_fade("res://addons/EasyMenus/Scenes/main_menu.tscn")



func _on_button_mouse_entered() -> void:
	sonido_boton.play()
