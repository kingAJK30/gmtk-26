extends Sprite2D

var rocket_ref: Node2D = null

func _process(_delta: float) -> void:
	var part = get_parent() as RocketPart
	if not part:
		return

	var is_flippable: bool = part.get("flippable") == true
	if not is_flippable:
		return

	if not is_instance_valid(rocket_ref):
		if part.target_rocket:
			rocket_ref = part.target_rocket
		else:
			rocket_ref = get_tree().current_scene.get_node_or_null("rocket")

	if not is_instance_valid(rocket_ref):
		return

	var local_pos = rocket_ref.to_local(global_position)

	if local_pos.x > 0:
		scale.x = -1
	else:
		scale.x = 1
