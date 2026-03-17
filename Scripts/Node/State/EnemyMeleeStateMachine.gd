class_name EnemyMeleeStateMachine extends StateMachine

@export var character : CombatCharacter

func _ready() -> void:
	states = {
		"idle" : NPCIdleState.new(),
		"strafe" : NPCAgroStrafeState.new(),
		"chase" : NPCChaseState.new(),
		"primary_atk" : EnemyNPCPrimaryAttackState.new(),
	}
	
	state_machine_setup()

func state_machine_setup() -> void:
	for state_key in states:
		var character_state : EnemyNPCState = states.get(state_key)
		if character_state != null:
			character_state.character = character
