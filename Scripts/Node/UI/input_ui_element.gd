extends Control
class_name InputTutorialUIElement

const DEVICE_INPUT_TEXTURES : DeviceInputTextures = preload("res://Resources/DeviceInputTextures/DefaultInputTextures.tres")

@export var action_name : String
@export var action_display_text : String

@export_subgroup("Nodes")
@export var input_texture_rect : TextureRect
@export var action_label : Label

var device = "keyboard"

func _ready() -> void:
	update()

func update():
	var input_textures : InputTextures = DEVICE_INPUT_TEXTURES.input_textures.get(device)
	input_texture_rect.texture = input_textures.textures.get(action_name)
	action_label.text = action_display_text
