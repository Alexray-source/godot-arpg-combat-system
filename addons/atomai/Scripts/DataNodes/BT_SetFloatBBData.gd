class_name BT_SetFloatBBData extends BT_NodeData

@export var bb_float_key : String
@export var new_float_value : float

func _init() -> void:
	resource_name = "Set Blackboard Float"

func create_node() -> BT_Node:
	var node : BT_SetFloatBB = BT_SetFloatBB.new()
	node.bb_float_key = bb_float_key
	node.new_float_value = new_float_value
	
	return node
