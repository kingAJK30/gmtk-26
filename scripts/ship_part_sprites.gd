extends Sprite2D

@onready var rocket_core = get_node("/root/game/rocket")


func _process(_delta: float) -> void:
		
	if global_position.x > rocket_core.global_position.x and get_parent().flippable==true:
		scale.x = -1
	else:
		scale.x = 1
