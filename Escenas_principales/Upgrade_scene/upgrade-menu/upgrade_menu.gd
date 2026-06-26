extends Node2D
@onready var control: Control = $Control
@onready var store: Button = $store
var _paused_by_menu: bool = false
const BASE_RES: Vector2 = Vector2(720, 1280)

func _ready() -> void:
	# start hidden, ensure UI continues processing when the tree is paused
	if is_instance_valid(control):
		control.hide()
		# process only when the game is paused so the menu responds while paused
		control.process_mode = Control.PROCESS_MODE_WHEN_PAUSED
	# make sure visible store button also processes while paused
	if is_instance_valid(store):
		store.show()
		# ensure the store button also inherits a suitable process mode (optional)
		store.process_mode = Control.PROCESS_MODE_INHERIT

func _on_store_pressed() -> void:
	if not is_instance_valid(control) or not is_instance_valid(store):
		return
	# pause the game only if it's not already paused by something else
	if not get_tree().paused:
		get_tree().paused = true
		_paused_by_menu = true
	control.show()
	store.hide()
	# set initial focus to the return button so keyboard/controller work
	var ret = control.get_node_or_null("return_button")
	if ret:
		ret.grab_focus()


func _on_return_button_pressed() -> void:
	if not is_instance_valid(control) or not is_instance_valid(store):
		return
	# only unpause if this menu paused the game
	if _paused_by_menu and get_tree().paused:
		get_tree().paused = false
		_paused_by_menu = false
	control.hide()
	store.show()
	# return focus to the store button
	store.grab_focus()
