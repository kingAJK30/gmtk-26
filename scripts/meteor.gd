extends Area2D

@export var movement_radius := 3.0
@export var movement_speed := 0.15

var origin: Vector2
var t := randf() * TAU

func _ready():
	origin = position

func _process(delta):
	rotation = sin(t) * 0.08
	t += delta * movement_speed

	position = origin + Vector2(
		 sin(t) * movement_radius,
		cos(t * 0.8) * movement_radius
	)
