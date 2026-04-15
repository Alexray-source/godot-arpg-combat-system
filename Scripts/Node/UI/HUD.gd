class_name PlayerHUD extends Control

@export var ability_energy_bar : Range
@export var abilities_ui : AbilitiesUIComponent

func update_ability_icon_fill(icon_index : int, new_value : float):
	abilities_ui.update_icon_fill(icon_index, new_value)

func activate_abililty(icon_index : int):
	abilities_ui.activate_abililty(icon_index)
