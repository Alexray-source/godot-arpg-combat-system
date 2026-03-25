@tool
class_name BT_SetStaggerImmuneData extends BT_NodeData

@export var character_bb_key : String = "character"
@export var stagger_immune : bool = false

func _init() -> void:
	resource_name = "Set Stagger Immune"

func create_node() -> BT_Node:
	var node : BT_SetStaggerImmune = BT_SetStaggerImmune.new()
	node.character_bb_key = character_bb_key
	node.stagger_immune = stagger_immune
	
	return node
