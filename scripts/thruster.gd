class_name Thruster
extends RocketPart

@export var max_thrust := 8000.0
@export var thruster_mass := 0.5
@export var flippable: bool = false

func _ready() -> void:
	super._ready()
	part_mass = thruster_mass


func _physics_process(_delta: float) -> void:
	
	if not is_attached or not target_rocket or not target_rocket.launched:
		return

	var force = -global_transform.y * max_thrust
	var global_offset = global_position - target_rocket.global_position

	target_rocket.apply_force(force, global_offset)
