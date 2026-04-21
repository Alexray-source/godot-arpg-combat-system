class_name BT_CharacterTeleportToPosition extends BT_Node

var character_bb_key : String
var target_position_bb_key : String
var randomnness_radius : float = 1.0

var teleport_delay : float = 0.15

var teleport_start_vfx_scene : PackedScene
var teleport_end_vfx_scene : PackedScene

var _finished : bool = false
var _status := RUNNING

func tick(blackboard : Dictionary):
	if _finished == true:
		return _status
	
	_finished = true
	
	var base_chr : BaseCharacter = blackboard.get(character_bb_key) as BaseCharacter
	var target_position : Vector3 = blackboard.get(target_position_bb_key) as Vector3
	
	if teleport_start_vfx_scene != null:
		var teleport_start_vfx = teleport_start_vfx_scene.instantiate()
		teleport_start_vfx.top_level = true
		base_chr.add_child(teleport_start_vfx)
		teleport_start_vfx.global_position = base_chr.global_position
	
	base_chr.get_tree().create_timer(teleport_delay).timeout.connect(teleport.bind(base_chr, target_position))
	
	return _status

func teleport(_chr, _position):
	var point_query_params : PhysicsPointQueryParameters3D = PhysicsPointQueryParameters3D.new()
	point_query_params.collide_with_areas = false
	point_query_params.collide_with_bodies = true
	point_query_params.collision_mask = 1
	point_query_params.position = _position
	
	var direct_space_state : PhysicsDirectSpaceState3D = _chr.get_world_3d().direct_space_state
	var query_result = direct_space_state.intersect_point(point_query_params)
	if query_result.size() > 0:
		_status = SUCCESS
		return
	
	_chr.global_position = _position + Vector3(randf_range(-randomnness_radius,randomnness_radius), 0.0, randf_range(-randomnness_radius,randomnness_radius))
	
	_status = SUCCESS
	
	if teleport_end_vfx_scene != null:
		var teleport_end_vfx : Node3D = teleport_end_vfx_scene.instantiate()
		teleport_end_vfx.top_level = true
		_chr.add_child(teleport_end_vfx)
		teleport_end_vfx.global_position = _chr.global_position

func reset(_blackboard : Dictionary):
	_status = RUNNING
	_finished = false
