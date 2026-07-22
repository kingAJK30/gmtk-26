class_name RocketPart
extends Area2D

signal part_attached
signal part_cancelled

@export var part_mass := 0.5

var is_dragging := false
var is_attached := false
var target_rocket: RigidBody2D = null

func _ready() -> void:
	input_pickable = false

func start_dragging() -> void:
	is_dragging = true

func _input(event: InputEvent) -> void:
	if not is_dragging:
		return
		
	if event.is_action_pressed("action_primary"):
		get_viewport().set_input_as_handled()
		_try_attach()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		get_viewport().set_input_as_handled()
		_cancel_placement()

func _process(_delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position()

func _try_attach() -> void:
	is_dragging = false
	
	var bodies = get_overlapping_bodies()
	
	for body in bodies:
		if body is RigidBody2D and body.has_method("launch"):
			target_rocket = body
			break
			
	if target_rocket:
		reparent(target_rocket, true)
		
		is_attached = true
		target_rocket.mass += part_mass
		part_attached.emit()
	else:
		_cancel_placement()

func _cancel_placement() -> void:
	is_dragging = false
	part_cancelled.emit()
	queue_free()

func apply_part_forces(_state: PhysicsDirectBodyState2D) -> void:
	pass
