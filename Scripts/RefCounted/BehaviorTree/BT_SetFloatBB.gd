class_name BT_SetFloatBB extends BT_Node

var bb_float_key : String
var new_float_value : float

func tick(blackboard : Dictionary):
	blackboard.set(bb_float_key, new_float_value)
