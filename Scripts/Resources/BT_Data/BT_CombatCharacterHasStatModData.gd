@tool
class_name BT_CombatCharacterHasStatModData extends BT_NodeData

@export var character_bb_key : String = "character"
@export var stat_modifier_key : String = ""

func _init() -> void:
	resource_name = "Chr. Has Stat Modifier"

func create_node() -> BT_Node:
	var node : BT_CombatCharacterHasStatMod = BT_CombatCharacterHasStatMod.new()
	node.character_bb_key = character_bb_key
	node.stat_modifier_key = stat_modifier_key
	
	return node
