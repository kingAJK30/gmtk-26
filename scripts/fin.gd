class_name Fin
extends RocketPart

@export var lift_strength := 12.0
@export var stability := 15
@export var flippable: bool = true

func _ready() -> void:
	super._ready()
	part_mass = 0.5

func _physics_process(_delta: float) -> void:
	if not is_attached or not target_rocket or not target_rocket.launched:
		return
	var global_offset = global_position - target_rocket.global_position
	var point_velocity = target_rocket.linear_velocity + Vector2(
		-target_rocket.angular_velocity * global_offset.y,
		target_rocket.angular_velocity * global_offset.x
	)

	if point_velocity.length() < 5.0:
		return

	var sideways = global_transform.x
	var forward = -global_transform.y

	var side_speed = point_velocity.dot(sideways)
	var capped_side_speed = clamp(side_speed, -250.0, 250.0)

	var correction_force = -sideways * capped_side_speed * lift_strength
	var redirect_force = forward * abs(capped_side_speed) * (lift_strength * 0.5)
	var force = (correction_force + redirect_force).limit_length(4000.0)

	target_rocket.apply_central_force(force)
	target_rocket.apply_torque(global_offset.cross(force))
