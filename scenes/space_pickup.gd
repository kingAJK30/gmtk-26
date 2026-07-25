class_name SpacePickup
extends Area2D

var part_scene: PackedScene
var preview_texture: Texture2D
var sprite: Sprite2D

func _ready() -> void:
	add_to_group("space_objects")
	body_entered.connect(_on_body_entered)

	if has_node("Sprite2D"):
		sprite = $Sprite2D
	else:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		add_child(sprite)

	if preview_texture:
		sprite.texture = preview_texture

	var tween = create_tween().set_loops()
	tween.tween_property(self, "rotation", TAU, 6.0).as_relative()

func setup(scene: PackedScene, texture: Texture2D) -> void:
	part_scene = scene
	preview_texture = texture
	if sprite and preview_texture:
		sprite.texture = preview_texture

func _on_body_entered(body: Node2D) -> void:
	if body is Rocket:
		if body.has_method("collect_part"):
			body.collect_part(part_scene)
		queue_free()
