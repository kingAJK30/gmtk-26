extends AnimatedSprite2D

@onready var smoke: GPUParticles2D = $Smoke

var fuel_depleted := false

func launch():
	play("start")
	animation_finished.connect(_on_animation_finished)
	
func _on_animation_finished() -> void:
	if animation == "start" and not fuel_depleted:
		play("default")

func _process(_delta: float) -> void:
	if animation == "default":
		smoke.emitting = true
	else:
		smoke.emitting = false

func _on_fuel_depleted() -> void:
	if fuel_depleted:
		return

	fuel_depleted = true
	play("end")
