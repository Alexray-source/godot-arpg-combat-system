class_name BT_WaitData extends BT_NodeData

@export var interval : float = 1.0

func create_node() -> BT_Node:
	var node = BT_Wait.new()
	node.interval = interval
	return node
