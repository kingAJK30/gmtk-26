extends AnimatedSprite2D

func _ready() -> void:
	SoundManager.play_explode()
	play()
	animation_finished.connect(queue_free)
