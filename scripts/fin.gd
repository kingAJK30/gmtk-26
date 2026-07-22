class_name Fin
extends RocketPart

@export var lift_strength := 30.0
@export var stability := 0.5

func _ready() -> void:
	super._ready()
	part_mass = 0.5

func _physics_process(_delta: float) -> void:
	if not is_attached or not target_rocket or not target_rocket.launched:
		return

	var velocity = target_rocket.linear_velocity
	if velocity.length() < 5.0:
		return

	var sideways = global_transform.x
	var side_speed = velocity.dot(sideways)
	var force = -sideways * side_speed * lift_strength
	var global_offset = global_position - target_rocket.global_position

	target_rocket.apply_force(force, global_offset)
