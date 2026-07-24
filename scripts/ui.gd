extends CanvasLayer

const THRUSTER_DATA = preload("res://resources/thruster_a.tres")
const FIN_DATA = preload("res://resources/fin_a.tres")

@onready var bottom_dock: Control = $Control/BottomDock
@onready var part_list_container: HBoxContainer = $Control/BottomDock/ScrollContainer/PartList

var inventory: Array[PartData] = []
var currently_dragging_part: RocketPart = null
var active_item_index: int = -1
var is_locked: bool = false

func _ready() -> void:
	_setup_starting_inventory()
	_populate_inventory_ui()

func _setup_starting_inventory() -> void:
	for i in range(3):
		inventory.append(THRUSTER_DATA)
	for i in range(2):
		inventory.append(FIN_DATA)

func add_part(part_resource: PartData) -> void:
	inventory.append(part_resource)
	_populate_inventory_ui()

func _populate_inventory_ui() -> void:
	for child in part_list_container.get_children():
		child.queue_free()

	for i in range(inventory.size()):
		var item: PartData = inventory[i]
		var button := Button.new()
		
		button.icon = item.icon
		button.expand_icon = true
		button.flat = true
		button.custom_minimum_size = Vector2(88, 88)
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.disabled = (currently_dragging_part != null or is_locked)
		button.pressed.connect(_on_item_clicked.bind(i))
		part_list_container.add_child(button)

func _on_item_clicked(index: int) -> void:
	if is_locked or currently_dragging_part != null or index < 0 or index >= inventory.size():
		return
		
	active_item_index = index
	var item: PartData = inventory[index]
	_spawn_part(item.scene)

func _spawn_part(part_scene: PackedScene) -> void:
	if not part_scene:
		push_error("Selected PartData is missing an assigned scene in the Inspector!")
		return

	var new_part: RocketPart = part_scene.instantiate()
	get_tree().current_scene.add_child(new_part)
	
	new_part.global_position = new_part.get_global_mouse_position()
	new_part.start_dragging()
	
	currently_dragging_part = new_part
	_populate_inventory_ui()
	
	new_part.part_attached.connect(_on_part_attached)
	new_part.part_cancelled.connect(_on_part_cancelled)

func _on_part_attached() -> void:
	if active_item_index != -1 and active_item_index < inventory.size():
		inventory.remove_at(active_item_index)
		
	active_item_index = -1
	currently_dragging_part = null
	_populate_inventory_ui()

func _on_part_cancelled() -> void:
	active_item_index = -1
	currently_dragging_part = null
	_populate_inventory_ui()

func hide_dock() -> void:
	is_locked = true
	_populate_inventory_ui()
	
	var screen_height = get_viewport().get_visible_rect().size.y
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(bottom_dock, "position:y", screen_height + 50.0, 0.6)

func show_dock() -> void:
	is_locked = false
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(bottom_dock, "position:y", 0.0, 0.6)
	tween.finished.connect(_populate_inventory_ui)
