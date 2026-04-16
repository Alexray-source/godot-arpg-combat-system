class_name BT_CharacterMoveTo extends BT_Node

var character_bb_key : String
var target_node_bb_key : String
var target_success_radius : float = 1.0
var target_offset : Vector3 = Vector3.ZERO
var timeout_time : float = 5.0
var accumulated_time : float = 0.0

var _reached_target : bool = false

func tick(blackboard : Dictionary):
	if _reached_target == true:
		return SUCCESS
	
	var base_chr : BaseCharacter = blackboard.get(character_bb_key) as BaseCharacter
	var target_node : Node3D = blackboard.get(target_node_bb_key) as Node3D
	var target_position : Vector3 = target_node.global_position + target_offset
	
	var delta = blackboard.get("delta")
	
	if accumulated_time > timeout_time:
		base_chr.move_dir = Vector3.ZERO
		return FAILURE
	
	accumulated_time += delta
	
	base_chr.move_dir = base_chr.global_position.direction_to(target_position)
	
	if base_chr.global_position.distance_to(target_position) < target_success_radius:
		_reached_target = true
		base_chr.move_dir = Vector3.ZERO
		return SUCCESS
	
	return RUNNING

func reset(_blackboard : Dictionary):
	_reached_target = false
	accumulated_time = 0.0
