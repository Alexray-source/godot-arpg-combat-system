@tool
class_name BT_CharacterTeleportToPosData extends BT_NodeData

@export var character_bb_key : String
@export var target_pos_bb_key : String
@export var randomnness_radius : float = 1.0

@export var delay : float = 0.15
@export var optional_vfx_start : PackedScene
@export var optional_vfx_end : PackedScene

func _init() -> void:
	resource_name = "Chr. Teleport To Position"

func create_node() -> BT_Node:
	var node = BT_CharacterTeleportToPosition.new()
	node.character_bb_key = character_bb_key
	node.target_position_bb_key = target_pos_bb_key
	node.randomnness_radius = randomnness_radius
	node.teleport_start_vfx_scene = optional_vfx_start
	node.teleport_end_vfx_scene = optional_vfx_end
	node.teleport_delay = delay
	return node
