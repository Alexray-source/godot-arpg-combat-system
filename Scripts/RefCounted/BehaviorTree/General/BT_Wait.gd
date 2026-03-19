class_name BT_Wait extends BT_Node

var interval : float = 1.0
var accumulated_time : float = 0.0

func tick(blackboard : Dictionary):
	var delta = blackboard.get("delta")
	
	accumulated_time += delta
	#print(accumulated_time)
	if accumulated_time > interval:
		return SUCCESS
	
	return RUNNING

func reset(blackboard : Dictionary):
	accumulated_time = 0.0
