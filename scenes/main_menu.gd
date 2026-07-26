extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $Options

func _ready() -> void:
	$Options/VBoxContainer/SFXVolContainer/SliderSFX.value_changed.connect(SoundManager.set_sfx_volume)
	$Options/VBoxContainer/MusicVolContainer/SliderBGM.value_changed.connect(SoundManager.set_bgm_volume)
	hide_menu()

func hide_menu() -> void:
	main_buttons.visible = true
	options.visible = false

func _on_launch_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_options_pressed() -> void:
	main_buttons.visible = false
	options.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_options_back_pressed() -> void:
	hide_menu()
