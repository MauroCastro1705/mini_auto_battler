extends Control
@onready var nav_1: Button = %nav_1
@onready var nav_2: Button = %nav_2
@onready var nav_3: Button = %nav_3
@onready var nav_4: Button = %nav_4
@onready var nav_5: Button = %nav_5

@export var nav_1_scene:Node2D
@export var nav_1_name:String

@export var nav_2_scene:Node2D
@export var nav_2_name:String

@export var nav_3_scene:Node2D
@export var nav_3_name:String

@export var nav_4_scene:Node2D
@export var nav_4_name:String

@export var nav_5_scene:Node2D
@export var nav_5_name:String

@onready var arrow1: TextureRect = $nav_bar/MarginContainer/HBoxContainer/VBoxContainer/arrow
@onready var arrow2: TextureRect = $nav_bar/MarginContainer/HBoxContainer/VBoxContainer2/arrow
@onready var arrow3: TextureRect = $nav_bar/MarginContainer/HBoxContainer/VBoxContainer3/arrow
@onready var arrow4: TextureRect = $nav_bar/MarginContainer/HBoxContainer/VBoxContainer4/arrow
@onready var arrow5: TextureRect = $nav_bar/MarginContainer/HBoxContainer/VBoxContainer5/arrow



var nav_1_active:bool = false
var nav_2_active:bool = false
var nav_3_active:bool = false
var nav_4_active:bool = false
var nav_5_active:bool = false

func _ready() -> void:
	nav_1.text = nav_1_name
	nav_2.text = nav_2_name
	nav_3.text = nav_3_name
	nav_4.text = nav_4_name
	nav_5.text = nav_5_name
	set_active_nav(3)


func _on_nav_1_pressed() -> void:
	set_active_nav(1)


func _on_nav_2_pressed() -> void:
	set_active_nav(2)


func _on_nav_3_pressed() -> void:
	set_active_nav(3)
	


func _on_nav_4_pressed() -> void:
	set_active_nav(4)


func _on_nav_5_pressed() -> void:
	set_active_nav(5)

func set_active_nav(active_index: int) -> void:
	nav_1_active = active_index == 1
	nav_2_active = active_index == 2
	nav_3_active = active_index == 3
	nav_4_active = active_index == 4
	nav_5_active = active_index == 5

	set_scene_visibility(nav_1_scene, nav_1_active)
	set_scene_visibility(nav_2_scene, nav_2_active)
	set_scene_visibility(nav_3_scene, nav_3_active)
	set_scene_visibility(nav_4_scene, nav_4_active)
	set_scene_visibility(nav_5_scene, nav_5_active)

func set_scene_visibility(scene: Node2D, is_visibles: bool) -> void:
	if scene == null:
		return
	if is_visibles:
		if scene.has_method("show"):
			scene.show()
		if scene.has_method("set_process"):
			scene.set_process(true)
		if scene.has_method("set_physics_process"):
			scene.set_physics_process(true)
		if scene.has_method("set_z_index"):
			scene.set_z_index(3)
	else:
		if scene.has_method("hide"):
			scene.hide()
		if scene.has_method("set_process"):
			scene.set_process(false)
		if scene.has_method("set_physics_process"):
			scene.set_physics_process(false)
		if scene.has_method("set_z_index"):
			scene.set_z_index(0)
