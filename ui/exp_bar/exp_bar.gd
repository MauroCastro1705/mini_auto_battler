extends Control
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

func _ready():
	Global.stats_updated.connect(update_xp)
	update_xp()

func update_xp():
	texture_progress_bar.value = Global.xp
	texture_progress_bar.max_value = Global.xp_to_next
