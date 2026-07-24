extends Node2D

enum GameState { BUILD, FLIGHT, SPACE }
var current_state: GameState = GameState.BUILD

@export var space_height := 3000
@export var space_drift_speed := 50.0

@onready var rocket: RigidBody2D = $rocket
@onready var ui: CanvasLayer = $UI

const METEOR_SCENES = [
	preload("res://scenes/meteors/meteor_small1.tscn"),
	preload("res://scenes/meteors/meteor_large1.tscn")
]

var space_initialized := false

func _on_timer_timeout() -> void:
	if current_state == GameState.BUILD:
		start_launch_sequence()

func start_launch_sequence() -> void:
	current_state = GameState.FLIGHT
	
	if ui and ui.has_method("hide_dock"):
		ui.hide_dock()
		
	rocket.launch()

func _process(_delta: float) -> void:
	match current_state:
		GameState.FLIGHT:
			if rocket and rocket.global_position.y < -space_height:
				current_state = GameState.SPACE
				print("ENTERED SPACE PHASE")
				_enter_space_phase()
				
		GameState.SPACE:
			if rocket:
				rocket.linear_velocity = Vector2(0.0, -space_drift_speed)

func _enter_space_phase() -> void:
	if space_initialized or not rocket:
		return
	space_initialized = true
	rocket.gravity_scale = 0.0
	rocket.linear_velocity = Vector2(0.0, -space_drift_speed)
	_spawn_meteor_field()

func _spawn_meteor_field() -> void:
	for i in range(15):
		var random_meteor_scene: PackedScene = METEOR_SCENES.pick_random()
		var meteor = random_meteor_scene.instantiate()
		
		var spawn_pos = rocket.global_position + Vector2(randf_range(-400, 400), -600 - (i * 350))
		meteor.global_position = spawn_pos
		
		get_tree().current_scene.add_child(meteor)
