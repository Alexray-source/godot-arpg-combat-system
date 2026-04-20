@tool
class_name BT_RequestAtkTokenEnemyData extends BT_NodeData

@export var character_bb_key : String = "character"
@export var enemy_character_bb_key : String = "enemy_character"
@export var token_lifetime : float = 2.0

func _init() -> void:
	resource_name = "Request enemy for combat token"

func create_node() -> BT_Node:
	var node : BT_RequestAtkTokenEnemy = BT_RequestAtkTokenEnemy.new()
	node.chr_bb_key = character_bb_key
	node.enemy_chr_bb_key = enemy_character_bb_key
	node.token_lifetime = token_lifetime
	
	return node
