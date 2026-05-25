class_name ClosestNode3DTracker extends RefCounted

var node_list : Array[Node3D]
var scan_origin : Vector3
var only_in_camera : bool = false
var camera : Camera3D

var _last_closest_node : Node3D

signal closest_node_changed(new_node : Node3D)

func poll(_delta : float):
	var _closest_dist : float = INF
	var _closest_node : Node3D
	for node in node_list:
		if only_in_camera == true:
			if camera.is_position_in_frustum(node.global_position) == false:
				continue
		
		var node_dist : float = node.global_position.distance_to(scan_origin) 
		if node.global_position.distance_to(scan_origin) < _closest_dist:
			_closest_dist = node_dist
			_closest_node = node
	
	if _last_closest_node != _closest_node:
		_last_closest_node = _closest_node
		closest_node_changed.emit(_closest_node)
	
