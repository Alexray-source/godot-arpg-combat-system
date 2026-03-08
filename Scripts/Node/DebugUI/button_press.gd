extends PanelContainer

const PRESSED_STYLE : StyleBox = preload("res://Debug/pressed_key_style.tres")
@export var action_name : String = "chr_primary_atk"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(action_name):
		add_theme_stylebox_override("panel", PRESSED_STYLE)
	elif event.is_action_released(action_name):
		remove_theme_stylebox_override("panel")
