class_name AbilitiesUIComponent extends Control

@export var icons : Array[AbilityIcon]
@export var modifier_icon : TextureRect
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

func set_modifier_visiblity(should_be_visible : bool):
	modifier_icon.visible = should_be_visible

func update_device(device : String):
	for icon in icons:
		icon.input_mode = device
		icon.set_input_icon()

func update_icon_fill(icon_index : int, new_value : float):
	var icon : AbilityIcon = icons[icon_index]
	icon.fill_progress_factor = new_value
