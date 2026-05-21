extends Control
class_name InputTutorialUI

const TUTORIAL_INPUT_UI_ELEMENT : PackedScene = preload("res://Scenes/UI/tutorial_input_ui_element.tscn")

@export var tutorial_actions : Dictionary[String, String]
@export var action_order : Array[String]
@export var tutorial_display_time : float = 10.0

@export_subgroup("Nodes")
@export var tutorial_panel : Control
@export var input_elements_holder : Control

var input_mode : String = "keyboard"

signal input_mode_changed(new_input_mode : String)

func _ready() -> void:
	change_input_mode(Input.get_connected_joypads().size() > 0)
	Input.joy_connection_changed.connect(func(_device : int, is_gamepad_connected : bool):
		change_input_mode.bind(is_gamepad_connected)
	)
	
	show_inputs(tutorial_actions, tutorial_display_time, action_order)
	GlobalSignals.plr_hud_state_changed.connect(on_hud_state_changed)

func on_hud_state_changed(new_state : bool):
	visible = new_state

func change_input_mode(is_gamepad_connected : bool):
	if is_gamepad_connected:
		input_mode = "xbox"
	else:
		input_mode = "keyboard"
	input_mode_changed.emit(input_mode)

func create_input_entry(action_id : String, action_display_text : String ) -> InputTutorialUIElement:
	var new_input_ui_element : InputTutorialUIElement = TUTORIAL_INPUT_UI_ELEMENT.instantiate() as InputTutorialUIElement
	
	new_input_ui_element.action_name = action_id
	new_input_ui_element.action_display_text = action_display_text
	new_input_ui_element.device = input_mode
	
	input_mode_changed.connect(func(new_input_mode): 
		new_input_ui_element.device = new_input_mode
		new_input_ui_element.update()
	)
	
	return new_input_ui_element

func show_inputs(_tutorial_actions : Dictionary[String, String], _tutorial_display_time : float = 5.0, _action_order : Array[String] = []) -> void:
	for action_id in _action_order:
		var new_input_ui_element : InputTutorialUIElement = create_input_entry(action_id, _tutorial_actions[action_id])
		
		input_elements_holder.add_child(new_input_ui_element)
	
	for action_id in _tutorial_actions:
		if _action_order.has(action_id):
			continue
		
		var new_input_ui_element : InputTutorialUIElement = create_input_entry(action_id, _tutorial_actions[action_id])
		
		input_elements_holder.add_child(new_input_ui_element)
	
	tutorial_panel.modulate = Color(1.0,1.0,1.0,0.0)
	tutorial_panel.scale = Vector2(1.5,1.5)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(tutorial_panel, "modulate", Color(1.0,1.0,1.0), 0.6)
	tween.tween_property(tutorial_panel, "scale", Vector2(1.0,1.0), 0.6)
	
	get_tree().create_timer(_tutorial_display_time).timeout.connect(queue_free, CONNECT_ONE_SHOT)
