@tool
class_name BT_CharacterMoveToData extends BT_NodeData

@export var character_bb_key : String
@export var target_node_bb_key : String
@export var target_success_radius : float = 1.0
@export var timeout_time : float = 5.0

func _init() -> void:
	resource_name = "Chr. Move To"

func create_node() -> BT_Node:
	var node = BT_CharacterMoveTo.new()
	node.character_bb_key = character_bb_key
	node.target_node_bb_key = target_node_bb_key
	node.target_success_radius = target_success_radius
	node.timeout_time = timeout_time
	return node
