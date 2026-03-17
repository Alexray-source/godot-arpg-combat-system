class_name EnemyNPCPrimaryAttackState extends EnemyNPCState

var atk_count : int = 0

func on_enter() -> void:
	if character.state_machine.get_state_by_key("knockback") == character.state_machine.current_state:
		return
	
	if character is CombatCharacter:
		atk_count = 0
		
		character.move_dir = Vector3(0.0,0.0,0.0)
		
		var combat_chr : CombatCharacter = character as CombatCharacter
		combat_chr.atk_debounce_ended.connect(continue_attack_chain.bind(combat_chr))
		continue_attack_chain(combat_chr)
		

func continue_attack_chain(combat_chr : CombatCharacter):
	await combat_chr.get_tree().create_timer(0.25).timeout
	
	atk_count += 1
	combat_chr.primary_attack()
	
	if atk_count > 2:
		combat_chr.atk_debounce_ended.disconnect(continue_attack_chain)
