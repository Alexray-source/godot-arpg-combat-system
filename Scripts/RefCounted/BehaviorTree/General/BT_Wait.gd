class_name BT_Wait extends BT_Node

var interval : float = 1.0
var randomness : float = 0.0
var accumulated_time : float = 0.0

var _current_randomness : float = 0.0

func tick(blackboard : Dictionary):
	var delta = blackboard.get("delta")
	
	accumulated_time += delta
	#print(accumulated_time)
	if accumulated_time > interval + _current_randomness:
		return SUCCESS
	
	return RUNNING

func reset(_blackboard : Dictionary):
	accumulated_time = 0.0
	_current_randomness = randf_range(0.0, randomness)
