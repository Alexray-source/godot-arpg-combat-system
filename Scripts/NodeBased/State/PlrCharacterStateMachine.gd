class_name PlrCharacterStateMachine extends StateMachine

var input_events : PlrInputEvents
@export var character : BaseCharacter

func _ready() -> void:
	states = {
		"movement" : PlrGroundMovement.new(),
		"primary_atk" : PlrAttackState.new(),
		"dodge_dash" : PlrDodgeState.new()
	}
	
	for i in range(3):
		var sp_attack_state = PlrSpecialAtkState.new()
		sp_attack_state.special_atk_index = i+1
		states["special_atk" + str(i+1)] = sp_attack_state
	
	state_machine_setup()

func state_machine_setup() -> void:
	for state_key in states:
		var character_state : PlrCharacterState = states.get(state_key)
		if character_state != null:
			character_state.input_events = input_events
			character_state.character = character
