class_name Meteor
extends Area2D

@export var movement_radius := 3.0
@export var movement_speed := 0.05

var origin: Vector2
var t := randf() * TAU
var player_rocket: Node2D

func _ready() -> void:
	add_to_group("space_objects")
	origin = global_position
	player_rocket = get_tree().get_first_node_in_group("rocket")
	
	# Connect the Area2D signal to detect when the rocket hits it
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	rotation += delta * 0.5
	t += delta * movement_speed

	global_position = origin + Vector2(
		sin(t) * movement_radius,
		cos(t * 0.8) * movement_radius
	)

	if player_rocket and global_position.y > player_rocket.global_position.y + 1000.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Rocket:
		if body.has_method("explode"):
			body.explode()
		queue_free()
