class_name BT_Invert extends BT_Composite

var interval : float = 1.0
var accumulated_time : float = 0.0

func tick(blackboard : Dictionary):
	var first_child = children[0]
	var result = first_child.tick(blackboard)
	
	if result == SUCCESS:
		return FAILURE
	elif result == FAILURE:
		return SUCCESS
	
	return RUNNING
