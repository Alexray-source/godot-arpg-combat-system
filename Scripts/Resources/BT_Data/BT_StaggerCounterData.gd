@tool
class_name BT_StaggerCounterData extends BT_NodeData

@export var character_bb_key : String = "character"
@export var stagger_count_treshold : int = 3

func _init() -> void:
	resource_name = "Check Stagger Count"

func create_node() -> BT_Node:
	var node : BT_StaggerCounter = BT_StaggerCounter.new()
	node.character_bb_key = character_bb_key
	node.stagger_count_treshold = stagger_count_treshold
	
	return node
