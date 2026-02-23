class_name CharacterStateMachine extends StateMachine

@export var character : BaseCharacter

func state_machine_setup() -> void:
	for state_key in states:
		var character_state : CharacterState = states.get(state_key)
		if character_state != null:
			character_state.character = character
