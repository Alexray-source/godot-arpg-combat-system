class_name TutorialUI_Spawner extends Node

const INPUT_TUTORIAL_UI = preload("res://Scenes/UI/TutorialUI.tscn")

var current_tutorial_ui : InputTutorialUI
var _should_be_visible_on_spawn : bool = true

func _ready() -> void:
	GlobalSignals.plr_hud_state_changed.connect(func(new_state : bool):
		_should_be_visible_on_spawn = new_state)
	
	GlobalSignals.plr_show_tutorial_action.connect(spawn_input_tutorial)

func spawn_input_tutorial(actions_display : TutorialActionDisplay):
	
	if current_tutorial_ui != null:
		current_tutorial_ui.queue_free()
	
	if actions_display != null:
		current_tutorial_ui = INPUT_TUTORIAL_UI.instantiate()
		current_tutorial_ui.on_hud_state_changed(_should_be_visible_on_spawn)
		current_tutorial_ui.tutorial_actions = actions_display.action_display_names
		current_tutorial_ui.action_order = actions_display.action_order
		
		add_child(current_tutorial_ui)
