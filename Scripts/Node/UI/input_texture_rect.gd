class_name InputTextureRect
extends TextureRect

@export var action_name : String

var input_mode : String = "keyboard"

const DEVICE_INPUT_TEXTURES : DeviceInputTextures = preload("res://Resources/DeviceInputTextures/DefaultInputTextures.tres")

func _ready() -> void:
	set_input_icon(input_mode)

func set_input_icon(new_input_mode : String) -> void:
	var device_textures = DEVICE_INPUT_TEXTURES.input_textures.get(new_input_mode)
	if device_textures == null:
		return
		
	var result_action_string = action_name
	var input_texture = device_textures.textures.get(result_action_string)
	
	texture = input_texture
