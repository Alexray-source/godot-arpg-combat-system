class_name BT_CheckFloatBB extends BT_Node

enum CompareMode {
	EQUAL,
	LESS,
	GREATER
}

var bb_float_key : String
var target_value : float
var compare_mode : CompareMode = CompareMode.EQUAL
var only_once : bool = false

var _result = FAILURE
var _finished : bool = false


func set_result(new_value):
	_result = new_value
	_finished = true
	#print(BT_ForceResult.ForcedResult.keys()[_result])
	return _result

func tick(blackboard : Dictionary):
	if _finished == true and only_once == true:
		return _result
	
	var key_value = blackboard.get(bb_float_key)
	
	if key_value == null:
		return set_result(FAILURE)
	
	match compare_mode:
		CompareMode.EQUAL:
			if is_equal_approx(key_value, target_value):
				return set_result(SUCCESS)
		
		CompareMode.LESS:
			if key_value < target_value:
				return set_result(SUCCESS)
		
		CompareMode.GREATER:
			if key_value > target_value:
				return set_result(SUCCESS)
	
	return set_result(FAILURE)

func reset(_blackboard : Dictionary):
	_finished = false
