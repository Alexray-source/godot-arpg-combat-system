@tool
class_name BT_CheckFloatBBData extends BT_NodeData

@export var bb_float_key : String
@export var target_value : float
@export var compare_mode : BT_CheckFloatBB.CompareMode
@export var only_once : bool = false

func _init() -> void:
	resource_name = "Check Blackboard Float"

func create_node() -> BT_Node:
	var node : BT_CheckFloatBB = BT_CheckFloatBB.new()
	node.bb_float_key = bb_float_key
	node.target_value = target_value
	node.compare_mode = compare_mode
	node.only_once = only_once
	
	return node
