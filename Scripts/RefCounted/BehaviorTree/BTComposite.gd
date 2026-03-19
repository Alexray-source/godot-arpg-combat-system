@abstract class_name BT_Composite extends BT_Node

var children : Array[BT_Node]

func reset(blackboard : Dictionary):
	for c in children:
		c.reset(blackboard)
