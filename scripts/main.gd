class_name Main
extends Node2D

enum GameState { BUILD, LAUNCH, SPACE }

@export_group("UI References")
@export var bottom_ui: CanvasLayer 

@export_group("Scene References")
@export var rocket: Rocket
@export var camera: Camera2D

@export_group("Hazard Spawning")
@export var meteor_scenes: Array[PackedScene] = []

@export_group("Space Loot & Return")
@export var build_duration := 5.0
@export var space_duration := 20.0
@export var space_altitude := -1500.0
@export var item_spawn_chance := 0.25
@export var space_pickup_scene: PackedScene

@export_subgroup("Spawnable Part Scenes")
@export var fin_scene: PackedScene
@export var thruster_scene: PackedScene
@export var scrap_scene: PackedScene

@export_subgroup("Part Textures")
@export var fin_texture: Texture2D
@export var thruster_texture: Texture2D
@export var scrap_texture: Texture2D

@export_group("Part Data Resources")
@export var thruster_data: PartData
@export var fin_data: PartData
@export var scrap_data: PartData

var current_state: GameState = GameState.BUILD
var build_timer := 0.0
var space_timer := 0.0
var meteor_spawn_timer := 0.0
var launchpad_position := Vector2.ZERO
var inventory: Array[PackedScene] = []

func _ready() -> void:
	if not bottom_ui:
		for child in get_tree().current_scene.get_children():
			if child is CanvasLayer and child.has_method("hide_dock"):
				bottom_ui = child
				print("Main: Auto-detected UI node.")
				break
				
	if not bottom_ui:
		push_error("MAIN CRITICAL: 'bottom_ui' is missing! The menu will not hide!")
	# -------------------------------------------------------------

	if bottom_ui and bottom_ui.has_method("show_dock"):
		bottom_ui.show_dock()

	if rocket:
		launchpad_position = rocket.global_position
		rocket.part_collected.connect(_on_part_collected)
	
	get_tree().root.size_changed.connect(_update_screen_borders)
	_update_screen_borders()

func _physics_process(delta: float) -> void:
	match current_state:
		GameState.BUILD:
			SoundManager.play_countdown_song()
			var prev_sec := int(ceil(build_duration - build_timer))
			build_timer += delta
			var curr_sec := int(ceil(build_duration - build_timer))
			
			if curr_sec != prev_sec and curr_sec in [1, 2, 3, 4, 5]:
				pass

			if build_timer >= build_duration:
				build_timer = 0.0
				_start_launch_phase()

		GameState.LAUNCH:
			if rocket and rocket.global_position.y <= space_altitude:
				_enter_space_phase()

		GameState.SPACE:
			_process_space_phase(delta)

func _start_launch_phase() -> void:
	current_state = GameState.LAUNCH
	
	if bottom_ui:
		if bottom_ui.has_method("hide_dock"):
			bottom_ui.hide_dock()
		else:
			push_error("MAIN CRITICAL: UI node found, but it has no 'hide_dock()' method!")
	else:
		push_error("MAIN CRITICAL: Cannot hide menu because bottom_ui is null!")
		
	if rocket:
		rocket.launch()

func _update_screen_borders() -> void:
	if not camera:
		return
		
	var visible_world_size := get_viewport_rect().size / camera.zoom
	var half_width := visible_world_size.x / 2.0
	var center_x := 306.0

	var left_x := center_x - half_width
	var right_x := center_x + half_width


	if has_node("Borders/left"):
		$Borders/left.position.x = left_x
	if has_node("Borders/right"):
		$Borders/right.position.x = right_x

	camera.limit_left = int(left_x)
	camera.limit_right = int(right_x)

func _enter_space_phase() -> void:
	SoundManager.play_main_song()
	print("SPAAACE REACHED!")
	current_state = GameState.SPACE
	if rocket:
		rocket.gravity_scale = 0.0
		rocket.linear_damp = 3.5

func _process_space_phase(delta: float) -> void:
	space_timer += delta

	if space_timer >= space_duration:
		_return_to_launchpad()
		return

	meteor_spawn_timer += delta
	if meteor_spawn_timer > 0.15:
		meteor_spawn_timer = 0.0
		
		if randf() < item_spawn_chance:
			_spawn_space_pickup_ahead()
		else:
			_spawn_meteor_ahead()

func _spawn_meteor_ahead() -> void:
	if meteor_scenes.is_empty():
		return

	var target_node: Node2D = null
	if rocket:
		target_node = rocket
	elif camera:
		target_node = camera

	if not target_node:
		return

	var meteor_scene: PackedScene = meteor_scenes.pick_random()
	var meteor_instance = meteor_scene.instantiate() as Node2D
	
	var spawn_x = target_node.global_position.x + randf_range(-400.0, 400.0)
	var spawn_y = target_node.global_position.y - randf_range(500.0, 800.0)
	
	meteor_instance.global_position = Vector2(spawn_x, spawn_y)
	meteor_instance.z_index = 5
	add_child(meteor_instance)

func _spawn_space_pickup_ahead() -> void:
	if not space_pickup_scene:
		return

	var target_node: Node2D = null
	if rocket:
		target_node = rocket
	elif camera:
		target_node = camera

	if not target_node:
		return

	var pickup = space_pickup_scene.instantiate() as SpacePickup
	var spawn_x = target_node.global_position.x + randf_range(-350.0, 350.0)
	var spawn_y = target_node.global_position.y - randf_range(500.0, 800.0)
	
	pickup.global_position = Vector2(spawn_x, spawn_y)
	pickup.z_index = 5

	var roll = randf()
	if roll < 0.4:
		pickup.setup(thruster_scene, thruster_texture)
	elif roll < 0.7:
		pickup.setup(fin_scene, fin_texture)
	else:
		pickup.setup(scrap_scene, scrap_texture)

	add_child(pickup)

func _on_part_collected(part_scene: PackedScene) -> void:
	SoundManager.play_pickup()
	if not bottom_ui:
		return

	if part_scene == thruster_scene and thruster_data:
		bottom_ui.add_part(thruster_data)
		print("Added Thruster to inventory!")
	elif part_scene == fin_scene and fin_data:
		bottom_ui.add_part(fin_data)
		print("Added Fin to inventory!")
	elif part_scene == scrap_scene and scrap_data:
		bottom_ui.add_part(scrap_data)
		print("Added Scrap to inventory!")

func _return_to_launchpad() -> void:
	SoundManager.stop_engine()
	current_state = GameState.BUILD
	space_timer = 0.0
	build_timer = 0.0

	if bottom_ui and bottom_ui.has_method("show_dock"):
		bottom_ui.show_dock()

	get_tree().call_group("space_objects", "queue_free")

	if rocket:
		rocket.freeze = true
		rocket.launched = false
		rocket.gravity_scale = 1.0
		rocket.linear_damp = 0.5
		rocket.global_position = launchpad_position
		rocket.rotation = 0.0
		rocket.linear_velocity = Vector2.ZERO
		rocket.angular_velocity = 0.0

	if camera:
		camera.global_position = launchpad_position
