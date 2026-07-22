extends CanvasLayer

const THRUSTER_SCENE = preload("res://scenes/thruster.tscn")
const FIN_SCENE = preload("res://scenes/fin.tscn")

@export var thruster_count := 5
@export var fin_count := 5

@onready var thruster_button: Button = $Control/BottomDock/PanelContainer/MarginContainer/PartList/ThrusterButton
@onready var fin_button: Button = $Control/BottomDock/PanelContainer/MarginContainer/PartList/FinButton

var currently_dragging_part: RocketPart = null

func _ready() -> void:
	thruster_button.pressed.connect(_on_thruster_pressed)
	fin_button.pressed.connect(_on_fin_pressed)
	_update_ui()

func _update_ui() -> void:
	thruster_button.text = "Thrusters: %d" % thruster_count
	fin_button.text = "Fins: %d" % fin_count
	
	thruster_button.disabled = thruster_count <= 0
	fin_button.disabled = fin_count <= 0

func _on_thruster_pressed() -> void:
	if thruster_count > 0 and currently_dragging_part == null:
		thruster_count -= 1
		_spawn_part(THRUSTER_SCENE, "thruster")
		_update_ui()

func _on_fin_pressed() -> void:
	if fin_count > 0 and currently_dragging_part == null:
		fin_count -= 1
		_spawn_part(FIN_SCENE, "fin")
		_update_ui()

func _spawn_part(part_scene: PackedScene, part_type: String) -> void:
	var new_part: RocketPart = part_scene.instantiate()
	get_tree().current_scene.add_child(new_part)
	new_part.global_position = new_part.get_global_mouse_position()
	new_part.start_dragging()
	currently_dragging_part = new_part
	new_part.part_attached.connect(_on_part_resolved)
	
	new_part.part_cancelled.connect(func():
		if part_type == "thruster":
			thruster_count += 1
		elif part_type == "fin":
			fin_count += 1
		_update_ui()
		_on_part_resolved()
	)

func _on_part_resolved() -> void:
	currently_dragging_part = null
