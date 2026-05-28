class_name BT_CharacterMoveTo extends BT_Node

var character_bb_key : String
var target_node_bb_key : String
var target_success_radius : float = 1.0
var target_offset : Vector3 = Vector3.ZERO
var timeout_time : float = 5.0
var timeout_result := FAILURE
var accumulated_time : float = 0.0
var ignore_y : bool = false

var _reached_target : bool = false

func tick(blackboard : Dictionary):
	if _reached_target == true:
		return SUCCESS
	
	var base_chr : BaseCharacter = blackboard_object_get(blackboard, character_bb_key)
	var target_node : Node3D = blackboard_object_get(blackboard, target_node_bb_key)
	
	if target_node == null or base_chr == null:
		return FAILURE
	
	var target_position : Vector3 = target_node.global_position + target_offset
	
	var delta = blackboard.get("delta")
	
	if accumulated_time > timeout_time:
		base_chr.move_dir = Vector3.ZERO
		return timeout_result
	
	accumulated_time += delta
	
	
	var chr_pos : Vector3 = base_chr.global_position
	
	if ignore_y == true:
		chr_pos = Vector3(chr_pos.x, 0.0, chr_pos.z)
		target_position = Vector3(target_position.x, 0.0, target_position.z)
	
	base_chr.move_dir = base_chr.global_position.direction_to(target_position)
	
	if chr_pos.distance_to(target_position) < target_success_radius:
		_reached_target = true
		base_chr.move_dir = Vector3.ZERO
		return SUCCESS
	
	return RUNNING

func reset(_blackboard : Dictionary):
	_reached_target = false
	accumulated_time = 0.0
