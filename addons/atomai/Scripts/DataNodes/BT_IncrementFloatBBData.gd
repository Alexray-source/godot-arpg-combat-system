@tool
class_name BT_IncrementFloatBBData extends BT_NodeData

@export var bb_float_key : String
@export var addition : float

func _init() -> void:
	resource_name = "Increment Blackboard Float"

func create_node() -> BT_Node:
	var node : BT_IncrementFloatBB = BT_IncrementFloatBB.new()
	node.bb_float_key = bb_float_key
	node.addition = addition
	
	return node
