class_name PlayerHUD extends Control

#@export var ability_energy_bar : Range
@export var abilities_ui : AbilitiesUIComponent
@export var health_bar : ProgressBar
@export var stamina_bar : ProgressBar
@export var grapple_mode_tex_rect : TextureRect

@export_subgroup("Temporary Testing")
@export var grapple_chr_texture : Texture2D
@export var grapple_obj_texture : Texture2D

var _stamina : float = 100.0
var _max_stamina : float = 100.0
var _stamina_bar_screen_pos : Vector2

func _ready() -> void:
	GlobalSignals.plr_hud_state_changed.connect(on_hud_state_changed)

func _process(delta: float) -> void:
	stamina_bar.value = _stamina/_max_stamina
	stamina_bar.global_position = _stamina_bar_screen_pos - (stamina_bar.size * stamina_bar.pivot_offset_ratio)

func on_hud_state_changed(new_state : bool):
	visible = new_state

func update_ability_icon_fill(icon_index : int, new_value : float):
	abilities_ui.update_icon_fill(icon_index, new_value)

func set_ability_icon(icon_index : int, new_icon : Texture2D):
	abilities_ui.set_ability_icon(icon_index, new_icon)

func activate_abililty(icon_index : int):
	abilities_ui.activate_abililty(icon_index)

func show_insufficient_ability_energy(icon_index : int):
	abilities_ui.insufficient_energy_notification(icon_index)

func update_health_bar(health : int, max_health : int):
	health_bar.value = health / float(max_health)

func update_grapple_mode(target_characters : bool):
	if target_characters == true:
		grapple_mode_tex_rect.texture = grapple_chr_texture
	else:
		grapple_mode_tex_rect.texture = grapple_obj_texture
