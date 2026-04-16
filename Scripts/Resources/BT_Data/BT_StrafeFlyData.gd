@tool
class_name BT_StrafeFlyData extends BT_NodeData

@export var character_bb_key : String
@export var target_node_bb_key : String
@export var strafe_height_relative_to_target : float = 5.0
@export var max_strafe_time : float = 4.0

func _init() -> void:
	resource_name = "Chr. Strafe (Flying)"

func create_node() -> BT_Node:
	var node : BT_StrafeFly = BT_StrafeFly.new()
	node.character_bb_key = character_bb_key
	node.target_bb_key = target_node_bb_key
	node.strafe_height_relative_to_target = strafe_height_relative_to_target
	node.max_strafe_time = max_strafe_time
	node.reset({})
	
	return node
