extends CanvasLayer

const THRUSTER_DATA = preload("res://resources/thruster_a.tres")
const FIN_DATA = preload("res://resources/fin_a.tres")

@onready var bottom_dock: Control = $Control/BottomDock
@onready var part_list_container: HBoxContainer = $Control/BottomDock/ScrollContainer/PartList
@onready var toolbox := $Control/BoxofToolsamr

@onready var pause_overlay: ColorRect = $Pause
@onready var pause_menu: Control = $Pause/PauseMenu
@onready var options_panel: Panel = $Pause/Options

@onready var resume_button: Button = $Pause/PauseMenu/MainButtons/Resume
@onready var options_button: Button = $Pause/PauseMenu/MainButtons/Options
@onready var exit_button: Button = $Pause/PauseMenu/MainButtons/Exit
@onready var options_back_button: Button = $Pause/Options/OptionsBack

var inventory: Array[PartData] = []
var currently_dragging_part: RocketPart = null
var active_item_index: int = -1
var is_locked: bool = false

func _ready() -> void:
	$Pause/Options/VBoxContainer/SFXVolContainer/SliderSFX.value_changed.connect(SoundManager.set_sfx_volume)
	$Pause/Options/VBoxContainer/MusicVolContainer/SliderBGM.value_changed.connect(SoundManager.set_bgm_volume)
	
	_hide_pause_ui()
	
	_setup_starting_inventory()
	_populate_inventory_ui()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	var is_paused := !get_tree().paused
	get_tree().paused = is_paused
	
	if is_paused:
		pause_overlay.visible = true
		_reset_pause_submenus()
	else:
		_hide_pause_ui()

func _reset_pause_submenus() -> void:
	pause_menu.visible = true
	options_panel.visible = false

func _hide_pause_ui() -> void:
	pause_overlay.visible = false
	pause_menu.visible = false
	options_panel.visible = false

func _on_resume_pressed() -> void:
	SoundManager.play_click()
	toggle_pause()

func _on_options_pressed() -> void:
	SoundManager.play_click()
	pause_menu.visible = false
	options_panel.visible = true
	
func _on_options_back_pressed() -> void:
	SoundManager.play_click()
	_reset_pause_submenus()

func _on_restart_pressed() -> void:
	SoundManager.play_click()
	SoundManager.stop_bgm()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_exit_pressed() -> void:
	SoundManager.play_click()
	get_tree().paused = false
	SoundManager.stop_engine()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# --- Inventory & Assembly Functions ---

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
	SoundManager.play_place()
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
	
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(bottom_dock, "modulate:a", 0.0, 0.4)
	tween.tween_callback(bottom_dock.hide)
	tween.tween_property(toolbox, "modulate:a", 0.0, 0.4)
	tween.tween_callback(toolbox.hide)

func show_dock() -> void:
	is_locked = false
	bottom_dock.show()
	_populate_inventory_ui()
	
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(bottom_dock, "modulate:a", 1.0, 0.4)
