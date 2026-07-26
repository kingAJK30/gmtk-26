extends Sprite2D

const START = preload("uid://b2sjilv8vf1kw")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var balloon = DialogueManager.show_dialogue_balloon(START)
	await balloon.tree_exited
	z_index = 10
	
	tutorial_done()
	get_parent().tutorial_done()

func tutorial_done() -> void:
	z_index = -10
