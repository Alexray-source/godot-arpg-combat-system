@tool
class_name BT_SetCharacterStateData extends BT_NodeData

@export var character_bb_key : String = "character"
@export var new_state : String = ""

func _init() -> void:
	resource_name = "Set Character State"

func create_node() -> BT_Node:
	var node : BT_SetCharacterState = BT_SetCharacterState.new()
	node.character_bb_key = character_bb_key
	node.new_state = new_state
	
	return node
