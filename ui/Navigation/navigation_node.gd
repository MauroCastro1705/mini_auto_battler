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



var nav_1_active:bool = true
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


func _on_nav_1_pressed() -> void:
	pass


func _on_nav_2_pressed() -> void:
	pass


func _on_nav_3_pressed() -> void:
	pass
	


func _on_nav_4_pressed() -> void:
	pass


func _on_nav_5_pressed() -> void:
	pass
