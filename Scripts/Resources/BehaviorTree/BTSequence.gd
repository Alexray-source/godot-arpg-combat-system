class_name BT_Sequence extends BT_Composite

func tick(blackboard : Dictionary):
	for c in children:
		var response = c.tick(blackboard)
		if response != SUCCESS:
			return response
	
	return SUCCESS
