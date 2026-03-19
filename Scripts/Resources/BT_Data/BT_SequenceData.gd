@tool
class_name BT_SequenceData extends BT_CompositeData

func create_node() -> BT_Node:
	var node : BT_Sequence = BT_Sequence.new()
	var created_children : Array[BT_Node]
	
	for node_data in children:
		var child_node = node_data.create_node()
		created_children.append(child_node)
	
	node.children = created_children
	
	return node
