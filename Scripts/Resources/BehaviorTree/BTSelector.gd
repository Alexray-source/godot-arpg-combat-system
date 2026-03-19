class_name BT_Selector extends BT_Composite

func tick(blackboard):
	for c in children:
		var response = c.tick(blackboard)
		if response != FAILURE:
			return response
	
	return FAILURE
