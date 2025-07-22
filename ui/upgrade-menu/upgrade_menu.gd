extends Node2D
@onready var control: Control = $Control
@onready var store: Button = $store

func _ready() -> void:
	control.hide()
	store.show()
	
func _on_store_pressed() -> void:
	get_tree().paused = true
	control.show()
	store.hide()


func _on_return_button_pressed() -> void:
	get_tree().paused = false
	control.hide()
	store.show()
