extends Node

var bgm_player: AudioStreamPlayer

func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = &"BGM"
	add_child(bgm_player)

func play_sfx(stream: AudioStream, pitch_rand: float = 0.1) -> void:
	if not stream:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = &"SFX"
	if pitch_rand > 0.0:
		player.pitch_scale = randf_range(1.0 - pitch_rand, 1.0 + pitch_rand)
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func play_bgm(stream: AudioStream) -> void:
	if not stream or bgm_player.stream == stream:
		return
	bgm_player.stream = stream
	bgm_player.play()
