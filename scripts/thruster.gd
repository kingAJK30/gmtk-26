class_name Thruster
extends RocketPart

@export var max_thrust := 2500.0
@export var thruster_mass := 0.6
@export var flippable: bool = false

func _ready() -> void:
	super._ready()
	part_mass = thruster_mass

func _physics_process(_delta: float) -> void:
	if not is_attached or not target_rocket or not target_rocket.launched:
		return

	var force_dir = Vector2.UP
	var total_force = force_dir * max_thrust

	target_rocket.apply_central_force(total_force)
