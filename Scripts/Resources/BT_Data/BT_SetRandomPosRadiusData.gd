@tool
class_name BT_SetRandomPosRadiusData extends BT_NodeData

@export var origin_node_bb_key : String = "character"
@export var target_pos_key : String
@export var horizontal_randomness : float = 5.0
@export var vertical_randomness : float = 0.0

func _init() -> void:
	resource_name = "Set Random Pos Within Radius"

func create_node() -> BT_Node:
	var node : BT_SetRandomPosRadius = BT_SetRandomPosRadius.new()
	node.origin_node_bb_key = origin_node_bb_key
	node.target_pos_key = target_pos_key
	node.horizontal_randomness = horizontal_randomness
	node.vertical_randomness = vertical_randomness
	
	return node
