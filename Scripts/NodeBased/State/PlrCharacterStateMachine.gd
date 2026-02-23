class_name PlrCharacterStateMachine extends StateMachine

var input_events : PlrInputEvents
@export var character : BaseCharacter

func state_machine_setup() -> void:
	for state_key in states:
		var character_state : PlrCharacterState = states.get(state_key)
		if character_state != null:
			character_state.input_events = input_events
			character_state.character = character
