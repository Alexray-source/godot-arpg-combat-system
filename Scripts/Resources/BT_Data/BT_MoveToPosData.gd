@tool
class_name BT_CharacterMoveToPosData extends BT_NodeData

@export var character_bb_key : String
@export var target_pos_bb_key : String
@export var target_success_radius : float = 1.0
@export var timeout_time : float = 5.0
@export var ignore_y : bool = false

func _init() -> void:
	resource_name = "Chr. Move To Pos"

func create_node() -> BT_Node:
	var node = BT_CharacterMoveToPosition.new()
	node.character_bb_key = character_bb_key
	node.target_position_bb_key = target_pos_bb_key
	node.target_success_radius = target_success_radius
	node.timeout_time = timeout_time
	node.ignore_y = ignore_y
	return node
