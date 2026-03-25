class_name Body3DScanner extends RefCounted

func scan(direct_space_state : PhysicsDirectSpaceState3D, hit_shape : Shape3D, hitbox_transform : Transform3D, scan_mask : int):
	var shape_cast_params = PhysicsShapeQueryParameters3D.new()
	shape_cast_params.shape = hit_shape
	shape_cast_params.transform = hitbox_transform
	shape_cast_params.collision_mask = scan_mask
	shape_cast_params.collide_with_areas = false
	shape_cast_params.collide_with_bodies = true
	
	#var sphere = SphereMesh.new()
	#sphere.height = hit_shape.radius * 2.0
	#sphere.radius = hit_shape.radius
	#
	#var mesh_inst = MeshInstance3D.new()
	#mesh_inst.mesh = sphere
	#mesh_inst.top_level = true
	#add_child(mesh_inst)
	#mesh_inst.global_position = shape_cast_params.transform.origin
	
	return direct_space_state.intersect_shape(shape_cast_params, 64)
