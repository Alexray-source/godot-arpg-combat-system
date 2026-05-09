class_name AbilitiesUIComponent extends Control

@export var icons : Array[AbilityIcon]

#var _cached_pos : Vector2
#var _shake_tween : Tween

#func _ready() -> void:
	#_cached_pos = position

func activate_abililty(icon_index : int):
	var icon : AbilityIcon = icons[icon_index]
	icon.activate_effect()

func insufficient_energy_notification(icon_index : int):
	var icon : AbilityIcon = icons[icon_index]
	icon.insufficient_energy_notification()

func set_ability_icon(icon_index : int, new_icon : Texture2D):
	var icon : AbilityIcon = icons[icon_index]
	icon.set_icon(new_icon)

func update_icon_fill(icon_index : int, new_value : float):
	var icon : AbilityIcon = icons[icon_index]
	icon.fill_progress_factor = new_value
