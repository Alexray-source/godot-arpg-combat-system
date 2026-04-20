@tool
class_name BT_ForceResultData extends BT_NodeData

@export var forced_result : BT_ForceResult.ForcedResult

func _init() -> void:
	resource_name = "Force Result"

func create_node() -> BT_Node:
	var node : BT_ForceResult = BT_ForceResult.new()
	node.forced_result = forced_result
	
	return node
