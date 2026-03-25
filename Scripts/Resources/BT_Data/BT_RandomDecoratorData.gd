@tool
class_name BT_RandomDecoratorData extends BT_CompositeData

@export var probability : float = 0.5

func _init() -> void:
	resource_name = "Random Probability"

func create_node() -> BT_Node:
	var node : BT_RandomDecorator = BT_RandomDecorator.new()
	node.probability = probability
	
	var first_child = children[0]
	var child_node = first_child.create_node()
	node.children.append(child_node)
	
	return node
