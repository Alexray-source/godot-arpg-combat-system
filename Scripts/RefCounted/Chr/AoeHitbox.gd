class_name AoeHitbox extends RefCounted

var hitbox_transform : Transform3D
var hit_shape : Shape3D
var atk_info : AtkInfo
var scan_mask : int = 1
var direct_space_state : PhysicsDirectSpaceState3D
var atk_dir_from_aoe_center : bool = false

signal hurtboxes_hit(hurtboxes : Array[HurtBox])

func attack() -> void:
	var shape_cast_params = PhysicsShapeQueryParameters3D.new()
	shape_cast_params.shape = hit_shape
	shape_cast_params.transform = hitbox_transform
	shape_cast_params.collision_mask = scan_mask
	shape_cast_params.collide_with_areas = true
	shape_cast_params.collide_with_bodies = false
	#print(shape_cast_params.collision_mask)
	#var sphere = SphereMesh.new()
	#sphere.height = hit_shape.radius * 2.0
	#sphere.radius = hit_shape.radius
	#
	#var mesh_inst = MeshInstance3D.new()
	#mesh_inst.mesh = sphere
	#mesh_inst.top_level = true
	#add_child(mesh_inst)
	#mesh_inst.global_position = shape_cast_params.transform.origin
	
	var results = direct_space_state.intersect_shape(shape_cast_params)
	var found_hitboxes : Array[HurtBox]
	for hit in results:
		var collider = hit.get("collider")
		if collider is HurtBox:
			var current_atk_info = atk_info
			found_hitboxes.append(collider)
			
			if atk_dir_from_aoe_center == true:
				var atk_dir = hitbox_transform.origin.direction_to(collider.global_position)
				current_atk_info = AtkInfo.new(atk_info.dmg, atk_info.atk_type, atk_info.instigator, atk_dir)
			
			collider.hit.emit(current_atk_info)
	
	if found_hitboxes.size() > 0:
		hurtboxes_hit.emit(found_hitboxes)
