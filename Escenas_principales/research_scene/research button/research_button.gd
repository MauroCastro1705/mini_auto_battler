extends Control
@onready var confirmation_container: HBoxContainer = %confirmation_container
@onready var button_yes: Button = %Button_yes
@onready var button_no: Button = %Button_no
@export var upgrade_price:int = 0
@export var upgrade_name:String = ""
@export var upgrade_text:String = ""
@export var upgrade_icon:Texture2D

@onready var icon_texture: TextureRect = %icon_texture
@onready var upgrade_name_local: Label = %upgrade_name

func _ready() -> void:
	confirmation_container.hide()
	icon_texture.texture = upgrade_icon
	upgrade_name_local.text = upgrade_name


func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on :
		confirmation_container.show()
	else:
		confirmation_container.hide()
	


func _on_button_yes_pressed() -> void:
	pass # Replace with function body.


func _on_button_no_pressed() -> void:
	pass # Replace with function body.
