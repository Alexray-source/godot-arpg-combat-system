class_name CharacterStateMachine extends StateMachine

@export var character : BaseCharacter

func _ready() -> void:
	states = {
		"ground_movement" : CharacterGroundState.new(),
		"air_movement" : CharacterAirState.new(),
		"attack" : CharacterPrimaryAttackState.new(),
		"dodge_dash" : CharacterDashState.new(),
		"stagger" : ChrStaggerState.new(),
		"knockback" : ChrKnockbackState.new(),
		"custom_movement" : CharacterCustomMovementState.new()
	}
	
	for i in range(3):
		var sp_attack_state = CharacterSpecialAttackState.new()
		sp_attack_state.special_atk_index = i+1
		states["sp_attack" + str(i+1)] = sp_attack_state

func state_machine_setup() -> void:
	for state_key in states:
		var character_state : CharacterState = states.get(state_key)
		if character_state != null:
			character_state.character = character
