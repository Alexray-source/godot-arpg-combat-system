class_name AbilitiesUIComponent extends Control

@export var icons : Array[AbilityIcon]
@export var tween_activate_trigger : Trigger
@export var tween_deactivate_trigger : Trigger

func set_special_indicator_state(is_active : bool):
	if is_active == true:
		tween_activate_trigger.execute({})
	else:
		tween_deactivate_trigger.execute({})

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
