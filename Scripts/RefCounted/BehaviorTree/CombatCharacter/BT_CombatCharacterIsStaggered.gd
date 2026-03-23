class_name BT_CharacterIsStaggered extends BT_Node

var character_bb_key : String

func tick(blackboard : Dictionary):
	var base_chr : CombatCharacter = blackboard.get(character_bb_key) as CombatCharacter
	
	if base_chr.state_machine.current_state ==  base_chr.state_machine.get_state_by_key("stagger"):
		return SUCCESS
	else:
		return FAILURE
