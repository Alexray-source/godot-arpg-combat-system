@tool
class_name BT_CheckCharacterStateData extends BT_NodeData

@export var character_bb_key : String = "character"
@export var state_to_check : String = ""

func _init() -> void:
	resource_name = "Check Character State"

func create_node() -> BT_Node:
	var node : BT_CheckCharacterState = BT_CheckCharacterState.new()
	node.character_bb_key = character_bb_key
	node.state_to_check = state_to_check
	
	return node
