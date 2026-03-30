@tool
class_name BT_StrafeData extends BT_NodeData

@export var character_bb_key : String
@export var target_node_bb_key : String
@export var max_strafe_time : float = 4.0

func _init() -> void:
	resource_name = "Chr. Strafe"

func create_node() -> BT_Node:
	var node : BT_Strafe = BT_Strafe.new()
	node.character_bb_key = character_bb_key
	node.target_bb_key = target_node_bb_key
	node.max_strafe_time = max_strafe_time
	node.reset({})
	
	return node
