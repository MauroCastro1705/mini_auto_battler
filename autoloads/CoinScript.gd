extends Node
var coin_target
var coin_layer

func register_coin_layer(node: Node) -> void:
	coin_layer = node
	print("[Global] coin_layer registered:", node.name, " is CanvasLayer:", node is CanvasLayer)

func get_coin_target_global_position() -> Vector2:
	if coin_target and is_instance_valid(coin_target) and coin_target.has_method("get_coin_target_global_position"):
		return coin_target.get_coin_target_global_position()
	return Vector2.ZERO

func get_resourse1_target_global_position() -> Vector2:
	if coin_target and is_instance_valid(coin_target) and coin_target.has_method("get_resourse1_target_global_position"):
		return coin_target.get_resourse1_target_global_position()
	return Vector2.ZERO

func get_resourse2_target_global_position() -> Vector2:
	if coin_target and is_instance_valid(coin_target) and coin_target.has_method("get_resourse2_target_global_position"):
		return coin_target.get_resourse2_target_global_position()
	return Vector2.ZERO

func add_money(amount: int) -> void:
	Global.player_money += amount
	Global.emit_signal("stats_updated")

func add_resource1(amount: int) -> void:
	Global.player_resource_1 += amount
	Global.emit_signal("stats_updated")

func add_resource2(amount: int) -> void:
	Global.player_resource_2 += amount
	Global.emit_signal("stats_updated")

func spawn_coin_from_sprite(sprite: Node, start_pos: Vector2, value: int, duration: float = 0.6) -> void:
	if not sprite:
		return

	var coin_instance: Node = sprite.duplicate() as Node
	if coin_instance is CanvasItem:
		(coin_instance as CanvasItem).visible = true

	# Choose parent: prefer registered coin_layer; if missing, auto-find the topmost CanvasLayer in the scene
	var parent_node: Node = null
	if coin_layer and is_instance_valid(coin_layer):
		parent_node = coin_layer
	else:
		# Search root children for CanvasLayer nodes and pick the one with highest layer value
		var best: CanvasLayer = null
		for n in get_tree().get_root().get_children():
			if n is CanvasLayer:
				if not best or (n.layer > best.layer):
					best = n
		if best:
			parent_node = best
		else:
			parent_node = get_tree().get_root()

	parent_node.add_child(coin_instance)

	# place at start (convert to canvas coords if parent is a CanvasLayer)
	var target = get_coin_target_global_position()
	if parent_node is CanvasLayer:
		var canvas_xform = get_viewport().get_canvas_transform()
		var start_canvas = canvas_xform * start_pos
		var target_canvas = canvas_xform * target
		if coin_instance is Node2D:
			coin_instance.position = start_canvas
		else:
			coin_instance.global_position = start_canvas
		target = target_canvas
	else:
		coin_instance.global_position = start_pos
	var t = get_tree().create_tween()
	t.tween_property(coin_instance, "global_position", target, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if coin_instance is Node2D:
		t.tween_property(coin_instance, "scale", Vector2(0.3, 0.3), duration)
	if coin_instance is CanvasItem:
		t.tween_property(coin_instance, "modulate:a", 0.0, duration)

	await t.finished

	add_money(value)

	if is_instance_valid(coin_instance):
		coin_instance.queue_free()


func spawn_resource1_from_sprite(sprite: Node, start_pos: Vector2, value: int, duration: float = 0.6) -> void:
	if not sprite:
		return

	var coin_instance: Node = sprite.duplicate() as Node
	if coin_instance is CanvasItem:
		(coin_instance as CanvasItem).visible = true

	var parent_node: Node = null
	if coin_layer and is_instance_valid(coin_layer):
		parent_node = coin_layer
	else:
		var best: CanvasLayer = null
		for n in get_tree().get_root().get_children():
			if n is CanvasLayer:
				if not best or (n.layer > best.layer):
					best = n
		if best:
			parent_node = best
		else:
			parent_node = get_tree().get_root()

	parent_node.add_child(coin_instance)

	var target = get_resourse1_target_global_position()
	if parent_node is CanvasLayer:
		var canvas_xform = get_viewport().get_canvas_transform()
		var start_canvas = canvas_xform * start_pos
		var target_canvas = canvas_xform * target
		if coin_instance is Node2D:
			coin_instance.position = start_canvas
		else:
			coin_instance.global_position = start_canvas
		target = target_canvas
	else:
		coin_instance.global_position = start_pos
	var t = get_tree().create_tween()
	t.tween_property(coin_instance, "global_position", target, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if coin_instance is Node2D:
		t.tween_property(coin_instance, "scale", Vector2(0.3, 0.3), duration)
	if coin_instance is CanvasItem:
		t.tween_property(coin_instance, "modulate:a", 0.0, duration)

	await t.finished

	add_resource1(value)

	if is_instance_valid(coin_instance):
		coin_instance.queue_free()


func spawn_resource2_from_sprite(sprite: Node, start_pos: Vector2, value: int, duration: float = 0.6) -> void:
	if not sprite:
		return

	var coin_instance: Node = sprite.duplicate() as Node
	if coin_instance is CanvasItem:
		(coin_instance as CanvasItem).visible = true

	var parent_node: Node = null
	if coin_layer and is_instance_valid(coin_layer):
		parent_node = coin_layer
	else:
		var best: CanvasLayer = null
		for n in get_tree().get_root().get_children():
			if n is CanvasLayer:
				if not best or (n.layer > best.layer):
					best = n
		if best:
			parent_node = best
		else:
			parent_node = get_tree().get_root()

	parent_node.add_child(coin_instance)

	var target = get_resourse2_target_global_position()
	if parent_node is CanvasLayer:
		var canvas_xform = get_viewport().get_canvas_transform()
		var start_canvas = canvas_xform * start_pos
		var target_canvas = canvas_xform * target
		if coin_instance is Node2D:
			coin_instance.position = start_canvas
		else:
			coin_instance.global_position = start_canvas
		target = target_canvas
	else:
		coin_instance.global_position = start_pos
	var t = get_tree().create_tween()
	t.tween_property(coin_instance, "global_position", target, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if coin_instance is Node2D:
		t.tween_property(coin_instance, "scale", Vector2(0.3, 0.3), duration)
	if coin_instance is CanvasItem:
		t.tween_property(coin_instance, "modulate:a", 0.0, duration)

	await t.finished

	add_resource2(value)

	if is_instance_valid(coin_instance):
		coin_instance.queue_free()
