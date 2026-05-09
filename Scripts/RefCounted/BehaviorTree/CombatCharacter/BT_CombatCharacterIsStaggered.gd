class_name BT_CharacterIsStaggered extends BT_Node

var character_bb_key : String

func tick(blackboard : Dictionary):
	var base_chr : CombatCharacter = blackboard_object_get(blackboard, character_bb_key)
	
	if base_chr == null:
		return FAILURE
	
	if base_chr.state_machine.current_state ==  base_chr.state_machine.get_state_by_key("stagger") or base_chr.state_machine.current_state ==   base_chr.state_machine.get_state_by_key("knockback"):
		return SUCCESS
	else:
		return FAILURE
