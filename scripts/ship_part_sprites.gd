extends Sprite2D

@onready var rocket_core = get_node("/root/game/rocket")

func _process(_delta: float) -> void:
	var local_pos = rocket_core.to_local(global_position)

	if local_pos.x > 0 and get_parent().flippable==true:
		scale.x = -1
	else:
		scale.x = 1
