class_name AbilitiesUIComponent extends Control

@export var icons : Array[AbilityIcon]

func update_icon_fill(icon_index : int, new_value : float):
	var icon : AbilityIcon = icons[icon_index]
	icon.fill_progress_factor = new_value
