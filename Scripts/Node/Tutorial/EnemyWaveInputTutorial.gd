extends Node


@export var enemy_wave_spawner : EnemyWaves
@export var enemy_wave_tutorials : Dictionary[int, TutorialActionDisplay]
@export var enabled : bool = false

#var current_tutorial_ui : InputTutorialUI

var _should_be_visible_on_spawn : bool = true

func _ready() -> void:
	enemy_wave_spawner.new_wave.connect(evaluate_wave)

func evaluate_wave(new_wave_number : int):
	if enabled == false:
		return
	
	var actions_display : TutorialActionDisplay = enemy_wave_tutorials.get(new_wave_number)
	print(actions_display)
	#if actions_display != null:
		#spawn_input_tutorial(actions_display)
	GlobalSignals.plr_show_tutorial_action.emit(actions_display)
