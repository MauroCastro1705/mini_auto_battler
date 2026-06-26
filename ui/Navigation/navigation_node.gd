extends Control
@onready var nav_1: Button = %nav_1
@onready var nav_2: Button = %nav_2
@onready var nav_3: Button = %nav_3
@onready var nav_4: Button = %nav_4
@onready var nav_5: Button = %nav_5

@export var nav_1_scene:PackedScene
@export var nav_2_scene:PackedScene
@export var nav_3_scene:PackedScene
@export var nav_4_scene:PackedScene
@export var nav_5_scene:PackedScene

@export var nav_1_name:String
@export var nav_2_name:String
@export var nav_3_name:String
@export var nav_4_name:String
@export var nav_5_name:String

func _ready() -> void:
	nav_1.text = nav_1_name
	nav_2.text = nav_2_name
	nav_3.text = nav_3_name
	nav_4.text = nav_4_name
	nav_5.text = nav_5_name

func _on_nav_1_pressed() -> void:
	SceneChanger.change_scene_with_fade_packed(nav_1_scene)


func _on_nav_2_pressed() -> void:
	SceneChanger.change_scene_with_fade_packed(nav_2_scene)


func _on_nav_3_pressed() -> void:
	SceneChanger.change_scene_with_fade_packed(nav_3_scene)


func _on_nav_4_pressed() -> void:
	SceneChanger.change_scene_with_fade_packed(nav_4_scene)


func _on_nav_5_pressed() -> void:
	SceneChanger.change_scene_with_fade_packed(nav_5_scene)
