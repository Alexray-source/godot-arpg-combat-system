class_name BT_IncrementFloatBB extends BT_Node

var bb_float_key : String
var addition : float

var _finished : bool = false

func tick(blackboard : Dictionary):
	if _finished == true:
		return SUCCESS
	
	var key_value = blackboard.get(bb_float_key)
	
	_finished = true
	
	if key_value == null:
		return FAILURE
	else:
		blackboard.set(bb_float_key, key_value + addition)
		return SUCCESS

func reset(_blackboard : Dictionary):
	_finished = false
