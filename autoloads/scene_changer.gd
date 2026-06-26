extends CanvasLayer

## usage SceneChanger.change_scene_with_fade("res://scenes/game.tscn")
## SceneChanger.change_scene_with_fade_packed(preload("res://path/to/scene.tscn"))

@onready var color_rect := ColorRect.new()
var tween: Tween

func _ready():
	# Fullscreen black overlay
	color_rect.color = Color.BLACK
	color_rect.visible = false
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(color_rect)
	
func change_scene_with_fade(path: String, duration: float = 0.5) -> void:
	if tween:
		tween.kill()

	color_rect.visible = true
	color_rect.modulate.a = 0.0

	tween = create_tween()

	# Fade to black
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)

	# Change scene in the middle
	tween.tween_callback(func():
		get_tree().change_scene_to_file(path)
	)

	# Fade back in
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)

	tween.tween_callback(func():
		color_rect.visible = false)

func change_scene_with_fade_packed(scene: PackedScene, duration: float = 0.5) -> void:
	if tween:
		tween.kill()

	color_rect.visible = true
	color_rect.modulate.a = 0.0

	tween = create_tween()

	# Fade to black
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)

	# Change scene in the middle
	tween.tween_callback(func():
		get_tree().change_scene_to_packed(scene)
	)

	# Fade back in
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)

	tween.tween_callback(func():
		color_rect.visible = false)
