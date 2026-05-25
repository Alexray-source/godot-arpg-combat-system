@tool
class_name BT_GetClosestThrowPosData extends BT_NodeData

@export var origin_node_scan_key : String
@export var found_throw_pos_key : String
@export var throw_node_target_key : String
@export var scan_radius : float = 25.0
@export var scan_once : bool = true
@export_custom(PROPERTY_HINT_LAYERS_3D_PHYSICS, "") var scan_layer : int = 16

func _init() -> void:
	resource_name = "Get Closest Throw Pos."

func create_node() -> BT_Node:
	var node = BT_GetClosestThrowPosition.new()
	node.origin_node_scan_key = origin_node_scan_key
	node.target_node_key = throw_node_target_key
	node.found_throw_pos_key = found_throw_pos_key
	node.scan_radius = scan_radius
	node.scan_layer = scan_layer
	node.scan_once = scan_once
	
	return node
