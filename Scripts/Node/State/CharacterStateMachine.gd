class_name CharacterStateMachine extends StateMachine

@export var character : BaseCharacter

func _ready() -> void:
	states = {
		"ground_movement" : CharacterGroundState.new(),
		"air_movement" : CharacterAirState.new(),
		"fly_movement" : CharacterFlyState.new(),
		"attack" : CharacterPrimaryAttackState.new(),
		"sp_attack" : CharacterSpecialAttackState.new(),
		"dodge_dash" : CharacterDashState.new(),
		"block" : CharacterBlockState.new(),
		"stagger" : ChrStaggerState.new(),
		"knockback" : ChrKnockbackState.new(),
		"custom_movement" : CharacterCustomMovementState.new(),
		"no_movement" : CharacterState.new(),
		"dead" : CharacterDeadState.new()
	}

func enter_special_atk_state(_special_atk_name) -> void:
	var sp_attack_state = states.get("sp_attack")
	sp_attack_state.ability_name = _special_atk_name
	transition_to_state(sp_attack_state)

func state_machine_setup() -> void:
	for state_key in states:
		var character_state : CharacterState = states.get(state_key)
		if character_state != null:
			character_state.character = character
