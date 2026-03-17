class_name EnemyNPCPrimaryAttackState extends EnemyNPCState

var _atk_count : int = 0
var max_atk_count : int = 3

func on_enter() -> void:
	if character.state_machine.get_state_by_key("knockback") == character.state_machine.current_state:
		state_end.emit()
		return
	
	_atk_count = 0
	
	if character is CombatCharacter:
		
		character.move_dir = Vector3(0.0,0.0,0.0)
		
		var combat_chr : CombatCharacter = character as CombatCharacter
		combat_chr.atk_debounce_ended.connect(continue_attack_chain.bind(combat_chr))
		continue_attack_chain(combat_chr)
		

func continue_attack_chain(combat_chr : CombatCharacter):
	await combat_chr.get_tree().create_timer(0.5).timeout
	
	_atk_count += 1
	combat_chr.primary_attack()
	
	if _atk_count > max_atk_count-1:
		if combat_chr.atk_debounce_ended.is_connected(continue_attack_chain):
			combat_chr.atk_debounce_ended.disconnect(continue_attack_chain)
		state_end.emit()
