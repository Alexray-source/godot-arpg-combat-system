class_name BT_Selector extends BT_Composite

func tick(blackboard):
	for c in children:
		running_child = c
		var response = c.tick(blackboard)
		if response != FAILURE:
			return response
	running_child = null
	return FAILURE
