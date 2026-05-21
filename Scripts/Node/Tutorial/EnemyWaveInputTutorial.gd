extends Node

const INPUT_TUTORIAL_UI = preload("res://Scenes/UI/TutorialUI.tscn")

@export var enemy_wave_spawner : EnemyWaves
@export var enemy_wave_tutorials : Dictionary[int, TutorialActionDisplay]
@export var enabled : bool = false

var current_tutorial_ui : InputTutorialUI

var _should_be_visible_on_spawn : bool = true

func _ready() -> void:
	enemy_wave_spawner.new_wave.connect(evaluate_wave)
	
	GlobalSignals.plr_hud_state_changed.connect(func(new_state : bool):
		_should_be_visible_on_spawn = new_state)

func evaluate_wave(new_wave_number : int):
	if enabled == false:
		return
	
	var actions_display : TutorialActionDisplay = enemy_wave_tutorials.get(new_wave_number)
	print(actions_display)
	if actions_display != null:
		spawn_input_tutorial(actions_display)

func spawn_input_tutorial(actions_display : TutorialActionDisplay):
	if current_tutorial_ui != null:
		current_tutorial_ui.queue_free()
	
	current_tutorial_ui = INPUT_TUTORIAL_UI.instantiate()
	current_tutorial_ui.on_hud_state_changed(_should_be_visible_on_spawn)
	current_tutorial_ui.tutorial_actions = actions_display.action_display_names
	current_tutorial_ui.action_order = actions_display.action_order
	
	add_child(current_tutorial_ui)
