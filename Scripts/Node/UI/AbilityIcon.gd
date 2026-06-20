class_name AbilityIcon extends Control

var fill_progress_factor : float:
	set(_value):
		fill_progress_factor = _value
		update_bar(_value)

@export var invert_visual_progress : bool
@export var icon : Texture2D
@export var icon_empty : Texture2D
@export var action_name : String
@export var input_side : Control.LayoutPreset = Control.LayoutPreset.PRESET_CENTER_BOTTOM

@export_subgroup("Nodes")
@export var icon_rect : TextureRect
@export var progress_bar : ProgressBar
@export var activate_layer : ColorRect

var _cached_pos : Vector2
var _shake_tween : Tween
var _current_tween : Tween
var _input_rect : TextureRect
var input_mode : String = "keyboard"

const NORMAL_MODULATE : Color = Color(1.0,1.0,1.0, 0.0)
const EMPTY_MODULATE : Color = Color(0.117, 0.117, 0.117, 1.0)
const DEVICE_INPUT_TEXTURES : DeviceInputTextures = preload("res://Resources/DeviceInputTextures/DefaultInputTextures.tres")

func _ready() -> void:
	_cached_pos = icon_rect.position
	set_icon(icon)
	set_input_icon()

func set_icon(new_icon : Texture2D) -> void:
	icon = new_icon
	if new_icon != null:
		icon_rect.texture = new_icon
		activate_layer.color = NORMAL_MODULATE
	else:
		icon_rect.texture = icon_empty
		activate_layer.color = EMPTY_MODULATE

func set_input_icon() -> void:
	var device_textures = DEVICE_INPUT_TEXTURES.input_textures.get(input_mode)

	if device_textures == null:
		return
		
	var result_action_string = action_name
	if input_mode != "keyboard":
		result_action_string += "_nomod"
	
	var input_texture = device_textures.textures.get(result_action_string)
	
	if input_texture == null:
		return
	
	if _input_rect != null and is_instance_valid(_input_rect):
		_input_rect.queue_free()
		
	_input_rect = TextureRect.new()
	_input_rect.texture = input_texture
	_input_rect.pivot_offset_ratio = Vector2(0.5,0.5)
	_input_rect.expand_mode = TextureRect.ExpandMode.EXPAND_IGNORE_SIZE
	
	add_child(_input_rect)
	_input_rect.set_anchors_preset(input_side, true)
	_input_rect.custom_minimum_size = Vector2(32,32)
	_input_rect.position -= _input_rect.custom_minimum_size * _input_rect.pivot_offset_ratio
	_input_rect.z_index = 10

func interupt_tweens():
	if _current_tween != null and _current_tween.is_running():
		_current_tween.stop()
	
	if _shake_tween != null and _shake_tween.is_running():
		_shake_tween.stop()

func activate_effect():
	interupt_tweens()
	
	activate_layer.color = Color(1.0,1.0,1.0)
	scale = Vector2(1.4,1.4)
	
	_current_tween = create_tween()
	_current_tween.set_ease(Tween.EASE_OUT)
	_current_tween.set_trans(Tween.TRANS_QUAD)
	_current_tween.set_parallel(true)
	_current_tween.tween_property(activate_layer, "color", Color(1.0,1.0,1.0,0.0), 0.5)
	_current_tween.tween_property(self, "scale", Vector2(1.0,1.0), 0.5)
	

func insufficient_energy_notification():
	interupt_tweens()
	
	activate_layer.color = Color(1.0, 0.0, 0.0, 1.0)
	scale = Vector2(1.4,1.4)
	
	_current_tween = create_tween()
	_current_tween.set_ease(Tween.EASE_OUT)
	_current_tween.set_trans(Tween.TRANS_QUAD)
	_current_tween.set_parallel(true)
	_current_tween.tween_property(activate_layer, "color", Color(1.0, 0.0, 0.0, 0.0), 0.5)
	_current_tween.tween_property(self, "scale", Vector2(1.0,1.0), 0.5)

	if _shake_tween != null and _shake_tween.is_running():
		_shake_tween.stop()
	
	_shake_tween = create_tween()
	_shake_tween.set_ease(Tween.EASE_OUT)
	_shake_tween.set_trans(Tween.TRANS_CIRC)
	_shake_tween.tween_method(shake_abilities, 1.0, 0.0, 0.5)

func shake_abilities(influence : float):
	var _shake_sine = sin(Time.get_ticks_msec() * 0.1)
	icon_rect.position = _cached_pos + Vector2(_shake_sine * 50.0 * influence, 0.0)


func update_bar(new_fill_factor : float):
	if progress_bar == null:
		return
	
	if invert_visual_progress == true:
		progress_bar.value = 1.0 - new_fill_factor
	else:
		progress_bar.value = new_fill_factor
