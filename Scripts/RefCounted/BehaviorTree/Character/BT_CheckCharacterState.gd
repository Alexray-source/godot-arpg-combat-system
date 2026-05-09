class_name BT_CheckCharacterState extends BT_Node

var character_bb_key : String = "character"
var state_to_check : String = ""

func tick(blackboard : Dictionary):
	var chr : BaseCharacter = blackboard_object_get(blackboard, character_bb_key)
	
	if chr == null:
		return FAILURE
	
	var check_result : bool = chr.state_machine.is_current_state_by_key(state_to_check)
	
	if check_result == true:
		return SUCCESS
	else:
		return FAILURE
