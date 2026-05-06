extends Control
class_name InputTutorialUI

const TUTORIAL_INPUT_UI_ELEMENT : PackedScene = preload("res://Scenes/UI/tutorial_input_ui_element.tscn")

@export var tutorial_actions : Dictionary[String, String]
@export var tutorial_display_time : float = 10.0

@export_subgroup("Nodes")
@export var input_elements_holder : Control

var input_mode : String = "keyboard"

signal input_mode_changed(new_input_mode : String)

func _ready() -> void:
	change_input_mode(Input.get_connected_joypads().size() > 0)
	Input.joy_connection_changed.connect(func(_device : int, is_gamepad_connected : bool):
		change_input_mode.bind(is_gamepad_connected)
	)
	
	show_inputs(tutorial_actions, tutorial_display_time)

func change_input_mode(is_gamepad_connected : bool):
	if is_gamepad_connected:
		input_mode = "xbox"
	else:
		input_mode = "keyboard"
	input_mode_changed.emit(input_mode)

func show_inputs(_tutorial_actions : Dictionary[String, String], _tutorial_display_time : float = 5.0) -> void:
	for action_id in tutorial_actions:
		var action_display_text = _tutorial_actions[action_id]
		var new_input_ui_element : InputTutorialUIElement = TUTORIAL_INPUT_UI_ELEMENT.instantiate() as InputTutorialUIElement
		
		new_input_ui_element.action_name = action_id
		new_input_ui_element.action_display_text = action_display_text
		new_input_ui_element.device = input_mode
		
		input_mode_changed.connect(func(new_input_mode): 
			new_input_ui_element.device = new_input_mode
			new_input_ui_element.update()
		)
		
		input_elements_holder.add_child(new_input_ui_element)
	
	get_tree().create_timer(_tutorial_display_time).timeout.connect(queue_free, CONNECT_ONE_SHOT)
