extends Node

const COUNT_SFX = preload("res://assets/audio/count.wav")
const ENGINE_SFX = preload("res://assets/audio/engine.wav")
const EXPLODE_SFX = preload("res://assets/audio/explode.wav")
const PICKUP_SFX = preload("res://assets/audio/pickup.wav")
const PLACE_SFX = preload("res://assets/audio/place.wav")

var bgm_player: AudioStreamPlayer
var engine_player: AudioStreamPlayer

func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = &"BGM"
	add_child(bgm_player)

	engine_player = AudioStreamPlayer.new()
	engine_player.stream = ENGINE_SFX
	engine_player.bus = &"SFX"
	engine_player.volume_db = -24.0
	add_child(engine_player)

func play_sfx(stream: AudioStream, pitch_rand: float = 0.1, volume_db: float = 0.0) -> void:
	if not stream:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = &"SFX"
	player.volume_db = volume_db
	if pitch_rand > 0.0:
		player.pitch_scale = randf_range(1.0 - pitch_rand, 1.0 + pitch_rand)
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func play_bgm(stream: AudioStream, volume_db: float = 0.0) -> void:
	if not stream or bgm_player.stream == stream:
		return
	bgm_player.stream = stream
	bgm_player.volume_db = volume_db
	bgm_player.play()


#  0.0  = 100% original volume
# -6.0  = roughly half volume
# -12.0 = roughly quarter volume
# +3.0  = louder
func play_count() -> void:
	play_sfx(COUNT_SFX, 0.0, -2.0)

func play_explode() -> void:
	play_sfx(EXPLODE_SFX, 0.1, 0.0)

func play_pickup() -> void:
	play_sfx(PICKUP_SFX, 0.15, -4.0)

func play_place() -> void:
	play_sfx(PLACE_SFX, 0.1, -1.0)

func start_engine(volume_db: float = -6.0) -> void:
	if engine_player:
		engine_player.volume_db = volume_db
		if not engine_player.playing:
			engine_player.play()

func stop_engine() -> void:
	if engine_player and engine_player.playing:
		engine_player.stop()
