class_name BT_CharacterTeleportToPosition extends BT_Node

var character_bb_key : String
var target_position_bb_key : String
var randomnness_radius : float = 1.0

var _finished : bool = false

func tick(blackboard : Dictionary):
	if _finished == true:
		return SUCCESS
	
	var base_chr : BaseCharacter = blackboard.get(character_bb_key) as BaseCharacter
	var target_position : Vector3 = blackboard.get(target_position_bb_key) as Vector3
	
	var point_query_params : PhysicsPointQueryParameters3D = PhysicsPointQueryParameters3D.new()
	point_query_params.collide_with_areas = false
	point_query_params.collide_with_bodies = true
	point_query_params.collision_mask = 1
	point_query_params.position = target_position
	
	var direct_space_state : PhysicsDirectSpaceState3D = base_chr.get_world_3d().direct_space_state
	var query_result = direct_space_state.intersect_point(point_query_params)
	if query_result.size() > 0:
		_finished = true
		return SUCCESS
	
	base_chr.global_position = target_position + Vector3(randf_range(-randomnness_radius,randomnness_radius), 0.0, randf_range(-randomnness_radius,randomnness_radius))
	
	_finished = true
	
	return SUCCESS

func reset(_blackboard : Dictionary):
	_finished = false
