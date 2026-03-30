@tool
class_name BT_SetChrMoveSpeedData extends BT_NodeData

@export var character_bb_key : String = "character"
@export var new_move_speed : float = 50.0

func _init() -> void:
	resource_name = "Set Chr. Move Speed"

func create_node() -> BT_Node:
	var node : BT_SetCharacterMoveSpeed = BT_SetCharacterMoveSpeed.new()
	node.character_bb_key = character_bb_key
	node.new_move_speed = new_move_speed
	
	return node
