class_name Meteor
extends Area2D

@export var movement_radius := 3.0
@export var movement_speed := 0.05

var origin: Vector2
var t := randf() * TAU
var player_rocket: Node2D

func _ready() -> void:
	add_to_group("space_objects")
	add_to_group("meteors")
	
	origin = global_position
	player_rocket = get_tree().get_first_node_in_group("rocket")
	
	body_entered.connect(_on_hit)
	area_entered.connect(_on_hit)

func _process(delta: float) -> void:
	rotation += delta * 0.5
	t += delta * movement_speed

	global_position = origin + Vector2(
		sin(t) * movement_radius,
		cos(t * 0.8) * movement_radius
	)

	if player_rocket and global_position.y > player_rocket.global_position.y + 1000.0:
		queue_free()

func _on_hit(node: Node2D) -> void:
	var target_rocket: Rocket = _find_rocket(node)
	if target_rocket:
		target_rocket.take_damage()
		queue_free()

func _find_rocket(node: Node2D) -> Rocket:
	if node is Rocket:
		return node
	if node is RocketPart and node.target_rocket:
		return node.target_rocket
	if node.get_parent() is RocketPart and node.get_parent().target_rocket:
		return node.get_parent().target_rocket
	if node.get_parent() is Rocket:
		return node.get_parent() as Rocket
	return null
