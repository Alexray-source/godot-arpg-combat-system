class_name BT_OnceDecorator extends BT_Composite

var _finished : bool = false

func tick(blackboard : Dictionary):
	if _finished == true:
		return SUCCESS
	
	for c in children:
		running_child = c
		var response = c.tick(blackboard)
		if response != SUCCESS:
			return response
	
	_finished = true
	return SUCCESS
