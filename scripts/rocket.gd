class_name Rocket
extends RigidBody2D

var launched := false

@export var hull_mass := 1.0
@export var hull_inertia := 20000.0
@export var explosion_scene: PackedScene

@export var base_lateral_accel := 1500.0
@export var base_lateral_braking := 300.0
@export var fin_accel_boost := 200.0
@export var fin_braking_boost := 1200.0
@export var max_lateral_speed := 350.0

@export var base_max_vertical_speed := 150.0
@export var thruster_speed_boost := 80.0

@export var mass_tilt_sensitivity: float = 0.05
@export var imbalance_torque_force: float = 50000.0
@export var tilt_drift_force: float = 1400.0

@export var base_angular_response: float = 3.5
@export var fin_angular_response: float = 6.0
@export var base_drift_damp: float = 40.0
@export var fin_drift_damp: float = 700.0

var attached_parts: Array[RocketPart] = []

signal part_collected(part_scene: PackedScene)

var _parts: Array[RocketPart] = []

func _ready() -> void:
	freeze = true
	angular_damp = 10.0
	linear_damp = 0.5
	center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
	mass = hull_mass
	inertia = hull_inertia

func collect_part(part_scene: PackedScene) -> void:
	part_collected.emit(part_scene)

func launch() -> void:
	print("ROCKET LAUNCHED")
	SoundManager.start_engine()
	launched = true
	freeze = false
	sleeping = false

func explode() -> void:
	print("BOOM BOOM BOOM")
	SoundManager.stop_engine()
	
	if explosion_scene:
		var explosion := explosion_scene.instantiate() as Node2D
		explosion.global_position = global_position
		get_parent().add_child(explosion)
	
	queue_free()

func _on_body_entered(_body: Node) -> void:
	explode()

func _physics_process(delta: float) -> void:
	if not launched:
		return

	var active_fins := 0
	var active_thrusters := 0
	var fin_imbalance := 0.0

	for part in attached_parts:
		if part is Fin and part.is_attached:
			active_fins += 1
			fin_imbalance += sign(part.position.x)
		elif part is Thruster and part.is_attached:
			active_thrusters += 1

	var steer := Input.get_axis("left", "right")

	var current_angular_response = base_angular_response + (active_fins * fin_angular_response)

	var com_offset_x := center_of_mass.x
	var total_tilt_bias := (com_offset_x * mass_tilt_sensitivity) + (fin_imbalance * 0.04)
	total_tilt_bias = clamp(total_tilt_bias, -0.35, 0.35)

	var target_angle := (steer * 0.15) - total_tilt_bias
	var angle_error := target_angle - rotation
	angular_velocity = angle_error * current_angular_response

	var current_accel = base_lateral_accel + (active_fins * fin_accel_boost)
	var veer_force := sin(rotation) * tilt_drift_force

	if steer != 0.0:
		apply_central_force(Vector2((steer * current_accel) + veer_force, 0.0))
	else:
		apply_central_force(Vector2(veer_force, 0.0))

	var current_damp = base_drift_damp + (active_fins * fin_drift_damp)

	if steer == 0.0 and abs(rotation) < 0.08:
		linear_velocity.x = move_toward(linear_velocity.x, 0.0, current_damp * delta)
	elif active_fins > 0:
		var target_vel = sin(rotation) * (max_lateral_speed + (active_fins * 50.0))
		linear_velocity.x = move_toward(linear_velocity.x, target_vel, current_damp * 0.4 * delta)

	var current_max_speed = max_lateral_speed + (active_fins * 50.0)
	linear_velocity.x = clamp(linear_velocity.x, -current_max_speed, current_max_speed)

	var current_max_vert_speed = base_max_vertical_speed + (active_thrusters * thruster_speed_boost)
	if linear_velocity.y < -current_max_vert_speed:
		linear_velocity.y = -current_max_vert_speed

func get_attachable_surfaces() -> Array[Node2D]:
	var surfaces: Array[Node2D] = [self]
	for part in attached_parts:
		if part is Scrap:
			surfaces.append(part)
	return surfaces

func get_node_global_rect(node: Node2D) -> Rect2:
	for child in node.get_children():
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
				return Rect2(child.global_position - (size * 0.5), size)

	for child in node.get_children():
		if child is Sprite2D and child.texture:
			var size = child.texture.get_size() * child.global_scale
			return Rect2(child.global_position - (size * 0.5), size)

	return Rect2(node.global_position - Vector2(20, 20), Vector2(40, 40))

func is_area_overlapping(proposed_rect: Rect2, ignore_part: RocketPart = null) -> bool:
	var check_rect = proposed_rect.grow(-1.0)
	for part in attached_parts:
		if part == ignore_part:
			continue
		var part_rect = get_node_global_rect(part)
		if check_rect.intersects(part_rect):
			return true
	return false

func find_available_outline_position(mouse_pos: Vector2, part_size: Vector2, ignore_part: RocketPart = null) -> Vector2:
	var best_pos := Vector2.ZERO
	var min_dist_sq := INF

	for surface in get_attachable_surfaces():
		var s_rect = get_node_global_rect(surface)
		var center = s_rect.get_center()
		var half_s = s_rect.size * 0.5
		var half_p = part_size * 0.5
		var diff = mouse_pos - center

		var is_side = abs(diff.x / half_s.x) > abs(diff.y / half_s.y) if half_s.x > 0 and half_s.y > 0 else true
		var base_snap := Vector2.ZERO

		if is_side:
			base_snap.x = center.x + (half_s.x + half_p.x) * (1.0 if diff.x >= 0 else -1.0)
			base_snap.y = clamp(mouse_pos.y, s_rect.position.y, s_rect.end.y)
		else:
			base_snap.y = center.y + (half_s.y + half_p.y) * (1.0 if diff.y >= 0 else -1.0)
			base_snap.x = clamp(mouse_pos.x, s_rect.position.x, s_rect.end.x)

		var step_dir = Vector2.UP if is_side else Vector2.RIGHT

		for offset in [0.0, 16.0, -16.0, 32.0, -32.0, 48.0, -48.0]:
			var test_pos = base_snap + (step_dir * offset)
			var prop_rect = Rect2(test_pos - half_p, part_size)

			if not is_area_overlapping(prop_rect, ignore_part):
				var dist_sq = mouse_pos.distance_squared_to(test_pos)
				if dist_sq < min_dist_sq:
					min_dist_sq = dist_sq
					best_pos = test_pos
				break

	return best_pos

func get_closest_outline_position(mouse_pos: Vector2, part_size: Vector2) -> Vector2:
	return find_available_outline_position(mouse_pos, part_size)

func attach_part(part: RocketPart, global_pos: Vector2) -> void:
	if not attached_parts.has(part):
		attached_parts.append(part)
		
	if part.get_parent():
		part.get_parent().remove_child(part)
	add_child(part)
	part.global_position = global_pos
	part.is_attached = true
	part.target_rocket = self
	
	recalculate_mass()

func register_part(part: RocketPart) -> void:
	attach_part(part, part.global_position)

func recalculate_mass() -> void:
	var total_mass := hull_mass
	var weighted_pos := Vector2.ZERO
	
	for part in attached_parts:
		total_mass += part.part_mass
		weighted_pos += part.position * part.part_mass

	mass = total_mass
	if total_mass > 0.0:
		center_of_mass = weighted_pos / total_mass

	var total_inertia := hull_inertia
	var com: Vector2 = center_of_mass
	for part in attached_parts:
		var r: Vector2 = part.position - com
		total_inertia += part.part_mass * r.length_squared()
		
	inertia = total_inertia
