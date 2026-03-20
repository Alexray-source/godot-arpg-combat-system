@tool
class_name BT_GetClosestCharacterData extends BT_NodeData

@export var origin_node_scan_key : String
@export var found_character_target_key : String
@export var scan_radius : float = 10.0
@export_custom(PROPERTY_HINT_LAYERS_3D_PHYSICS, "") var scan_layer : int = 1

func _init() -> void:
	resource_name = "Get Closest Chr."

func create_node() -> BT_Node:
	var node = BT_GetClosestCharacter.new()
	node.origin_node_scan_key = origin_node_scan_key
	node. found_character_target_key = found_character_target_key
	node.scan_radius = scan_radius
	node.scan_layer = scan_layer
	
	return node
