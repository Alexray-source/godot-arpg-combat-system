class_name AbilityIcon extends Control

var fill_progress_factor : float:
	set(_value):
		fill_progress_factor = _value
		update_bar(_value)

@export var invert_visual_progress : bool
@export var icon : Texture2D
@export var icon_empty : Texture2D

@export_subgroup("Nodes")
@export var icon_rect : TextureRect
@export var progress_bar : ProgressBar
@export var activate_layer : Control

var _cached_pos : Vector2
var _shake_tween : Tween

const NORMAL_MODULATE : Color = Color(1.0,1.0,1.0, 0.0)
const EMPTY_MODULATE : Color = Color(0.117, 0.117, 0.117, 1.0)

func _ready() -> void:
	_cached_pos = icon_rect.position
	set_icon(icon)

func set_icon(new_icon : Texture2D) -> void:
	icon = new_icon
	if new_icon != null:
		icon_rect.texture = new_icon
		activate_layer.modulate = NORMAL_MODULATE
	else:
		icon_rect.texture = icon_empty
		activate_layer.modulate = EMPTY_MODULATE

func activate_effect():
	activate_layer.modulate = Color(1.0,1.0,1.0)
	scale = Vector2(1.4,1.4)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_parallel(true)
	tween.tween_property(activate_layer, "modulate", Color(1.0,1.0,1.0,0.0), 0.5)
	tween.tween_property(self, "scale", Vector2(1.0,1.0), 0.5)
	

func insufficient_energy_notification():
	activate_layer.modulate = Color(1.0, 0.0, 0.0, 1.0)
	scale = Vector2(1.4,1.4)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_parallel(true)
	tween.tween_property(activate_layer, "modulate", Color(1.0, 0.0, 0.0, 0.0), 0.5)
	tween.tween_property(self, "scale", Vector2(1.0,1.0), 0.5)

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
