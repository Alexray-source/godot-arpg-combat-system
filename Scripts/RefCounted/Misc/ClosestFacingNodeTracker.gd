class_name ClosestFacingNode3DTracker extends RefCounted

var node_list : Array[Node3D]
var scan_transform : Transform3D
var only_in_camera : bool = false
var camera : Camera3D
var ignore_y : bool = false

var _last_closest_node : Node3D

signal closest_node_changed(new_node : Node3D)

func get_closest_facing_node() -> Node3D:
	return _last_closest_node

func poll(_delta : float):
	var _closest_dot_result : float = -1.0
	var _closest_node : Node3D
	for node in node_list:
		if only_in_camera == true:
			if camera.is_position_in_frustum(node.global_position) == false:
				continue
		
		var from_pos : Vector3 = scan_transform.origin
		var to_pos : Vector3 = node.global_position
		var look_vector = -scan_transform.basis.z
		
		if ignore_y == true:
			from_pos = Vector3(from_pos.x, 0.0, from_pos.z)
			to_pos = Vector3(to_pos.x, 0.0, to_pos.z)
			look_vector = Vector3(look_vector.x, 0.0, look_vector.z).normalized()
		
		var direction_to_node = from_pos.direction_to(to_pos)
		var node_dot_direction_result = look_vector.dot(direction_to_node)
		if node_dot_direction_result > _closest_dot_result:
			_closest_dot_result = node_dot_direction_result
			_closest_node = node
	
	if _last_closest_node != _closest_node:
		_last_closest_node = _closest_node
		closest_node_changed.emit(_closest_node)
	
