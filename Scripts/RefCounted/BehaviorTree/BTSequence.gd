class_name BT_Sequence extends BT_Composite

func tick(blackboard : Dictionary):
	for c in children:
		var response = c.tick(blackboard)
		running_child = c
		if response != SUCCESS:
			return response
	running_child = null
	return SUCCESS
