@tool
class_name BT_InvertDecoratorData extends BT_CompositeData

func _init() -> void:
	resource_name = "Invert Decorator"

func create_node() -> BT_Node:
	var node : BT_Invert = BT_Invert.new()
	
	var first_child = children[0]
	var child_node = first_child.create_node()
	node.children.append(child_node)
	
	return node
