class_name BT_CombatCharacterAbilityData extends BT_NodeData

@export var character_bb_key : String
@export var target_node_bb_key : String
@export var ability_name : String

func create_node() -> BT_Node:
	var node = BT_CombatCharacterAbility.new()
	node.character_bb_key = character_bb_key
	node.target_node_bb_key = target_node_bb_key
	node.ability_name = ability_name 
	
	return node
