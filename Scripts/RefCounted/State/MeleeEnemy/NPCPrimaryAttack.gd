class_name EnemyNPCPrimaryAttackState extends EnemyNPCState

func on_enter() -> void:
	if character.state_machine.get_state_by_key("knockback") == character.state_machine.current_state:
		return
	
	if character is CombatCharacter:
		character.move_dir = Vector3(0.0,0.0,0.0)
		
		var combat_chr : CombatCharacter = character as CombatCharacter
		combat_chr.primary_attack()
