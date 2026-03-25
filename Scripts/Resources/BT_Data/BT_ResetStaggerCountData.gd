@tool
class_name BT_ResetStaggerCountData extends BT_NodeData

@export var character_bb_key : String = "character"

func _init() -> void:
	resource_name = "Reset Stagger Counter"

func create_node() -> BT_Node:
	var node : BT_ResetStaggerCount = BT_ResetStaggerCount.new()
	node.character_bb_key = character_bb_key
	
	return node
