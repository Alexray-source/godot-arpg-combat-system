class_name BT_CombatCharacterHasStatMod extends BT_Node

var character_bb_key : String
var stat_modifier_key : String

var _finished : bool = false

func tick(blackboard : Dictionary):
	if _finished == true:
		return SUCCESS
	
	var base_chr : CombatCharacter = blackboard_object_get(blackboard, character_bb_key)
	
	if base_chr == null:
		return FAILURE
	
	if base_chr.has_stat_modifier(stat_modifier_key) == true:
		return SUCCESS
	else:
		return FAILURE

func reset(_blackboard : Dictionary):
	_finished = false
