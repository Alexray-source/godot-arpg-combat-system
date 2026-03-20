@tool
class_name BT_SelectorData extends BT_CompositeData

func _init() -> void:
	resource_name = "Selector"

func create_node() -> BT_Node:
	var node : BT_Selector = BT_Selector.new()
	var created_children : Array[BT_Node]
	
	for node_data in children:
		var child_node = node_data.create_node()
		created_children.append(child_node)
	
	node.children = created_children
	
	return node
