class_name PlayerHUD extends Control

#@export var ability_energy_bar : Range
@export var abilities_ui : AbilitiesUIComponent
@export var health_bar : ProgressBar
@export var stamina_bar : ProgressBar
@export var target_indicator_rect : TextureRect
@export var target_input_rect : InputTextureRect

@export_subgroup("Temporary Testing")
@export var target_inactive_color : Color
@export var target_active_color : Color

var _stamina : float = 100.0
var _max_stamina : float = 100.0
var _stamina_bar_screen_pos : Vector2
var _input_mode : String = "keyboard"

signal input_mode_changed(new_input_mode : String)

func _ready() -> void:
	change_input_mode(Input.get_connected_joypads().size() > 0)
	Input.joy_connection_changed.connect(func(_device : int, is_gamepad_connected : bool):
		change_input_mode.bind(is_gamepad_connected)
	)
	
	GlobalSignals.plr_hud_state_changed.connect(on_hud_state_changed)
	input_mode_changed.connect(on_input_mode_changed)
	on_input_mode_changed(_input_mode)


func _process(_delta: float) -> void:
	stamina_bar.value = _stamina/_max_stamina
	stamina_bar.global_position = _stamina_bar_screen_pos - (stamina_bar.size * stamina_bar.pivot_offset_ratio)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("gamepad_action_btn"):
		abilities_ui.set_special_indicator_state(true)
	elif event.is_action_released("gamepad_action_btn"):
		abilities_ui.set_special_indicator_state(false)

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

func update_target_mode(is_active : bool):
	if is_active == true:
		target_indicator_rect.self_modulate = target_active_color
	else:
		target_indicator_rect.self_modulate = target_inactive_color

func change_input_mode(is_gamepad_connected : bool):
	if is_gamepad_connected:
		_input_mode = "xbox"
	else:
		_input_mode = "keyboard"
	input_mode_changed.emit(_input_mode)

func on_input_mode_changed(new_input_mode : String):
	abilities_ui.set_modifier_visiblity(new_input_mode != "keyboard")
	abilities_ui.update_device(new_input_mode)
	
	target_input_rect.set_input_icon(new_input_mode)
