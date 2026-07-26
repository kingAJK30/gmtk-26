class_name RocketPart
extends Area2D

signal part_attached
signal part_cancelled

@export var part_mass: float = 0.5

var is_attached := false
var is_dragging := false
var target_rocket: RigidBody2D = null

func _ready() -> void:
	input_event.connect(_on_input_event)

func start_dragging() -> void:
	is_dragging = true
	is_attached = false
	global_position = get_global_mouse_position()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not is_attached:
			is_dragging = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and is_dragging:
			is_dragging = false
			_try_attach()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if is_dragging:
			is_dragging = false
			is_attached = false
			part_cancelled.emit()
			queue_free()

func _process(_delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position()

func get_part_rect(at_position: Vector2) -> Rect2:
	for child in get_children():
		if child is CollisionShape2D and child.shape:
			var shape = child.shape
			var size := Vector2.ZERO
			
			if shape is RectangleShape2D:
				size = shape.size * scale
			elif shape is CircleShape2D:
				var diameter = shape.radius * 2.0
				size = Vector2(diameter, diameter) * scale
			elif shape is CapsuleShape2D:
				size = Vector2(shape.radius * 2.0, shape.height) * scale
			
			if size != Vector2.ZERO:
				var offset = child.position * scale
				return Rect2((at_position + offset) - (size * 0.5), size)

	for child in get_children():
		if child is Sprite2D and child.texture:
			var size = child.texture.get_size() * child.global_scale
			var offset = child.position * child.global_scale
			return Rect2((at_position + offset) - (size * 0.5), size)

	return Rect2(at_position - Vector2(15, 15), Vector2(30, 30))

func _try_attach() -> void:
	var rocket: Rocket = get_tree().current_scene.find_child("rocket", true, false) as Rocket
	
	if not rocket or rocket.launched:
		is_attached = false
		part_cancelled.emit()
		queue_free()
		return

	var mouse_pos = get_global_mouse_position()
	var part_size = get_part_rect(global_position).size
	var snapped_pos = rocket.get_closest_outline_position(mouse_pos, part_size)
	var max_drop_distance := 12.0
	
	if mouse_pos.distance_to(snapped_pos) > max_drop_distance:
		is_attached = false
		part_cancelled.emit()
		queue_free()
		return

	var proposed_rect = get_part_rect(snapped_pos)
	if not rocket.is_area_overlapping(proposed_rect, self):
		rocket.attach_part(self, snapped_pos)
		part_attached.emit()
		return

	is_attached = false
	part_cancelled.emit()
	queue_free()
