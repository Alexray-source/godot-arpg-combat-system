@tool
class_name BT_CharacterIsStaggeredData extends BT_NodeData

@export var character_bb_key : String

func _init() -> void:
	resource_name = "Is Character Staggered"

func create_node() -> BT_Node:
	var node = BT_CharacterIsStaggered.new()
	node.character_bb_key = character_bb_key
	
	return node
