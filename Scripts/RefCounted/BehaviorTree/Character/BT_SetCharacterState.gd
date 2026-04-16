class_name BT_SetCharacterState extends BT_Node

var character_bb_key : String = "character"
var new_state : String = ""

var _finished : bool = false

func tick(blackboard : Dictionary):
	if _finished == true:
		return SUCCESS
	
	var chr = blackboard.get(character_bb_key) as BaseCharacter
	chr.set_state(new_state)
	_finished = true
	
	return SUCCESS

func reset(_blackboard : Dictionary):
	_finished = false
