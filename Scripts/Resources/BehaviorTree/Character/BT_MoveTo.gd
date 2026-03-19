class_name BT_CharacterMoveTo extends BT_Node

@export var chr_bb_key : String
@export var target_node_bb_key : String
@export var target_success_radius : float = 1.0
@export var timeout_time : float = 5.0
var accumulated_time : float = 0.0

func tick(blackboard : Dictionary):
	
	var base_chr : BaseCharacter = blackboard.get(chr_bb_key) as BaseCharacter
	var target_node : Node3D = blackboard.get(target_node_bb_key) as Node3D
	
	var delta = blackboard.get("delta")
	
	if accumulated_time > timeout_time:
		base_chr.move_dir = Vector3.ZERO
		return FAILURE
	
	accumulated_time += delta
	
	base_chr.move_dir = base_chr.global_position.direction_to(target_node.global_position)
	
	if base_chr.global_position.distance_to(target_node.global_position) < target_success_radius:
		base_chr.move_dir = Vector3.ZERO
		return SUCCESS
	
	return RUNNING

func reset(blackboard : Dictionary):
	accumulated_time = 0.0
