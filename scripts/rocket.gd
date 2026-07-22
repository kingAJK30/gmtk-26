extends RigidBody2D

var launched := false

func _ready() -> void:
	freeze = true

func launch() -> void:
	print("ROCKET LAUNCHED")
	launched = true
	freeze = false
	sleeping = false

func explode() -> void:
	print("BOOM BOOM BOOM")
	queue_free()

func _on_body_entered(_body: Node) -> void:
	if launched and linear_velocity.length() > 100:
		explode()
