class_name PlayerHUD extends Control

@export var ability_energy_bar : Range
@export var abilities_ui : AbilitiesUIComponent
@export var health_bar : ProgressBar

func update_ability_icon_fill(icon_index : int, new_value : float):
	abilities_ui.update_icon_fill(icon_index, new_value)

func set_ability_icon_visiblity(icon_index : int, new_visible : bool):
	abilities_ui.icons[icon_index].visible = new_visible

func activate_abililty(icon_index : int):
	abilities_ui.activate_abililty(icon_index)

func update_health_bar(health : int, max_health : int):
	health_bar.value = health / float(max_health)
