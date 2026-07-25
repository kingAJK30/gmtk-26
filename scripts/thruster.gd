class_name Thruster
extends RocketPart

@export var max_thrust := 2500.0
@export var thruster_mass := 0.6
@export var flippable: bool = false
@export var fuel_duration := 5.0

@onready var fire: AnimatedSprite2D = $Fire

var fuel_remaining := 5.0
var is_out_of_fuel := false
var launched := false

func _ready() -> void:
	super._ready()
	part_mass = thruster_mass

func _physics_process(_delta: float) -> void:
	if not is_attached or not target_rocket or not target_rocket.launched:
		return

	var force_dir = Vector2.UP
	var total_force = force_dir * max_thrust

	if launched == false:
		if fire and fire.has_method("launch"):
			fire.launch()
		launched = true

	var offset := global_position - target_rocket.global_position

	target_rocket.apply_central_force(total_force)
	target_rocket.apply_torque(offset.cross(total_force))


func _on_fuel_depleted() -> void:
	for child in get_children():
		if child.has_method("_on_fuel_depleted"):
			child._on_fuel_depleted()
	print("%s ran out of fuel!" % name)
