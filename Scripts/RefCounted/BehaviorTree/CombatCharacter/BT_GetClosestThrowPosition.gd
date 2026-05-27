class_name BT_GetClosestThrowPosition extends BT_Node

var origin_node_scan_key : String
var found_throw_pos_key : String
var target_node_key : String
var scan_radius : float = 10.0
var scan_layer : int = 1
var scan_once : bool

var _found_pos : bool = false
var _finished : bool = false

func tick(blackboard : Dictionary):
	if _found_pos == true and _finished == true:
		return SUCCESS
	elif _finished == true:
		return FAILURE
	
	if scan_once == true:
		_finished = true
	
	var scan_shape : SphereShape3D = SphereShape3D.new()
	scan_shape.radius = scan_radius
	
	var origin : Node3D = blackboard.get(origin_node_scan_key) as Node3D
	var throw_target_node : Node3D = blackboard.get(target_node_key) as Node3D

	var direct_space_state : PhysicsDirectSpaceState3D = origin.get_world_3d().direct_space_state
	
	#print(blackboard.get(origin_node_scan_key))
	
	var closest_throwable : Throwable
	var closest_throwable_dist : float = INF
	var throwable_scanner = Body3DScanner.new()
	
	var throwable_scan_result : Array[Dictionary] = throwable_scanner.scan(direct_space_state, scan_shape, origin.global_transform.orthonormalized(), scan_layer)

	for result in throwable_scan_result:
		var collider = result.get("collider")
		#print(collider)
		if collider is Throwable:
			if collider.global_position.distance_to(origin.global_position) < closest_throwable_dist:
				closest_throwable_dist = collider.global_position.distance_to(origin.global_position)
				closest_throwable = collider
	
	#print(closest_throwable)
	if throw_target_node != null and closest_throwable != null:
		var closest_throw_pos : Vector3 = closest_throwable.global_position + (-closest_throwable.global_position.direction_to(throw_target_node.global_position) * 1.5)
		

		_found_pos = true
		blackboard.set(found_throw_pos_key, closest_throw_pos)
		return SUCCESS
	
	return FAILURE

func reset(_blackboard : Dictionary):
	_found_pos = false
	_finished = false
