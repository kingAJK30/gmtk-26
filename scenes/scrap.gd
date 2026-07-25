class_name Scrap
extends RocketPart

@export var scrap_mass := 0.3

func _ready() -> void:
	super._ready()
	part_mass = scrap_mass
