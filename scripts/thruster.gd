class_name Thruster
extends RocketPart

@export var max_thrust := 2500
@export var thruster_mass := 0.6
@export var flippable: bool = false
@export var fuel_duration := 5.0

var fuel_remaining := 5.0
var is_out_of_fuel := false

func _ready() -> void:
	super._ready()
	part_mass = thruster_mass
	fuel_remaining = fuel_duration

func _physics_process(delta: float) -> void:
	if not is_attached or not target_rocket or not target_rocket.launched or is_out_of_fuel:
		return

	fuel_remaining -= delta
	if fuel_remaining <= 0.0:
		fuel_remaining = 0.0
		is_out_of_fuel = true
		_on_fuel_depleted()
		return

	var force_dir = -global_transform.y
	var total_force = force_dir * max_thrust
	var global_offset = global_position - target_rocket.global_position

	target_rocket.apply_central_force(total_force)
	target_rocket.apply_torque(global_offset.cross(total_force))
	

func _on_fuel_depleted() -> void:
	print("%s ran out of fuel!" % name)
