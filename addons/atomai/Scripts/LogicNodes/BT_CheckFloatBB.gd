class_name BT_CheckFloatBB extends BT_Node

enum CompareMode {
	EQUAL,
	LESS,
	GREATER
}

var bb_float_key : String
var target_value : float
var compare_mode : CompareMode = CompareMode.EQUAL

func tick(blackboard : Dictionary):
	var key_value = blackboard.get(bb_float_key)
	
	if key_value == null:
		return FAILURE
	
	match compare_mode:
		CompareMode.EQUAL:
			if is_equal_approx(key_value, target_value):
				return SUCCESS
		
		CompareMode.LESS:
			if key_value < target_value:
				return SUCCESS
		
		CompareMode.GREATER:
			if key_value > target_value:
				return SUCCESS
