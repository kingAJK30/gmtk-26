class_name Fin
extends RocketPart

@export var flippable: bool = true

func _ready() -> void:
	super._ready()
	part_mass = 0.0
