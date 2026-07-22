extends Node2D

@onready var rocket = $rocket

func _on_timer_timeout():
	rocket.launch()
