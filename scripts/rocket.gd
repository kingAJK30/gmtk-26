class_name Rocket
extends RigidBody2D

var launched := false
@export var steer_torque := 50000.0
@export var hull_mass := 1.0
@export var hull_inertia := 20000.0
@export var max_angular_speed := 1

var _parts: Array[RocketPart] = []

func _ready() -> void:
	freeze = true
	angular_damp = 2.5
	linear_damp = 0.0
	center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
	mass = hull_mass
	inertia = hull_inertia

func register_part(part: RocketPart) -> void:
	_parts.append(part)
	_recalculate_mass_properties()

func _recalculate_mass_properties() -> void:
	var total_mass := hull_mass
	var weighted_pos := Vector2.ZERO
	for part in _parts:
		total_mass += part.part_mass
		weighted_pos += part.position * part.part_mass

	var com := weighted_pos / total_mass

	var total_inertia := hull_inertia
	for part in _parts:
		var r := part.position - com
		total_inertia += part.part_mass * r.length_squared()

	mass = total_mass
	center_of_mass = com
	inertia = total_inertia

func _physics_process(_delta: float) -> void:
	if not launched:
		return
	var steer := Input.get_axis("left", "right")
	if steer != 0.0:
		apply_torque(steer * steer_torque)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.angular_velocity = clamp(state.angular_velocity, -max_angular_speed, max_angular_speed)

func launch() -> void:
	print("ROCKET LAUNCHED")
	launched = true
	freeze = false
	sleeping = false

func explode() -> void:
	print("BOOM BOOM BOOM")
	queue_free()

func _on_body_entered(_body: Node) -> void:
	if launched and linear_velocity.length() > 0:
		explode()
