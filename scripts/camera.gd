extends Camera2D

@export var target: Node2D

func _process(_delta: float) -> void:
	if is_instance_valid(target):
		global_position = target.global_position
		global_rotation = 0.0
