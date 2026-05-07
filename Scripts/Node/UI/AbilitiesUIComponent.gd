class_name AbilitiesUIComponent extends Control

@export var icons : Array[AbilityIcon]

var _cached_pos : Vector2
var _shake_tween : Tween

func _ready() -> void:
	_cached_pos = position

func activate_abililty(icon_index : int):
	var icon : AbilityIcon = icons[icon_index]
	icon.activate_effect()

func insufficient_energy_notification(icon_index : int):
	var icon : AbilityIcon = icons[icon_index]
	icon.insufficient_energy_notification()
	
	if _shake_tween != null and _shake_tween.is_running():
		_shake_tween.stop()
	
	_shake_tween = create_tween()
	_shake_tween.set_ease(Tween.EASE_OUT)
	_shake_tween.set_trans(Tween.TRANS_CIRC)
	_shake_tween.tween_method(shake_abilities, 1.0, 0.0, 0.5)

func shake_abilities(influence : float):
	var _shake_sine = sin(Time.get_ticks_msec() * 0.1)

	position = _cached_pos + Vector2(_shake_sine * 50.0 * influence, 0.0)


func update_icon_fill(icon_index : int, new_value : float):
	var icon : AbilityIcon = icons[icon_index]
	icon.fill_progress_factor = new_value
