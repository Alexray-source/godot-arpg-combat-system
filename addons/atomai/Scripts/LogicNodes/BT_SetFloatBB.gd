class_name BT_SetFloatBB extends BT_Node

var bb_float_key : String
var new_float_value : float

var _finished : bool

func tick(blackboard : Dictionary):
	if _finished == true:
		#print(BT_ForceResult.ForcedResult.keys()[SUCCESS])
		return SUCCESS
	
	blackboard.set(bb_float_key, new_float_value)
	_finished = true

func reset(_blackboard : Dictionary):
	_finished = false
