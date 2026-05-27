class_name ClosestFacingNode3DTracker extends RefCounted

var node_list : Array[Node3D]
var scan_transform : Transform3D
var only_in_camera : bool = false
var camera : Camera3D

var _last_closest_node : Node3D

signal closest_node_changed(new_node : Node3D)

func poll(_delta : float):
	var _closest_dot_result : float = -1.0
	var _closest_node : Node3D
	for node in node_list:
		if only_in_camera == true:
			if camera.is_position_in_frustum(node.global_position) == false:
				continue
		
		var direction_to_node = scan_transform.origin.direction_to(node.global_position)
		var node_dot_direction_result = -scan_transform.basis.z.dot(direction_to_node)
		if node_dot_direction_result > _closest_dot_result:
			_closest_dot_result = node_dot_direction_result
			_closest_node = node
	
	if _last_closest_node != _closest_node:
		_last_closest_node = _closest_node
		closest_node_changed.emit(_closest_node)
	
