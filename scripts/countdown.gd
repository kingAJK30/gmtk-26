extends AnimatedSprite2D

@export var pulse_scale := 1.15
@export var shrink_scale := 0.9
@export var pulse_duration := 0.75
@export var rotation_amount := 10.0

var growth := 1.0
var pulse := 1.0

var growth_scale = 1
var pulse_count := 0

func _process(_delta):
	scale = Vector2.ONE * growth * pulse
	growth_scale += 0.001

func _ready():

# Start smooth back-and-forth rotation
	var spin = create_tween().set_loops()
	spin.tween_property(self, "rotation_degrees", rotation_amount, pulse_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	spin.tween_property(self, "rotation_degrees", -rotation_amount, pulse_duration * 2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	spin.tween_property(self, "rotation_degrees", 0.0, pulse_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	# Wait 0.5 seconds before starting the pulse loop.
	await get_tree().create_timer(0.5).timeout

	while pulse_count < 4:
		var tween = create_tween()
		var grow = create_tween()

		# Shrink
		tween.tween_property(self, "pulse", shrink_scale, pulse_duration * 0.2)

		# Expand
		tween.tween_property(self, "pulse", pulse_scale * 1.5, pulse_duration * 0.4)
		grow.tween_property(self, "growth", growth_scale, pulse_duration * 0.4)

		# Return to normal
		tween.tween_property(self, "pulse", 1.0, pulse_duration * 0.4)

		pulse_count += 1

		await get_tree().create_timer(1.0).timeout
		
		
	var disappear = create_tween()
	disappear.tween_property(self, "growth", 0, 0.25)
	await disappear.finished
	get_parent().get_parent().queue_free()
