extends Projectile

func _ready() -> void:
	direct_space_state = get_world_3d().direct_space_state
	
	ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.collide_with_areas = true
	ray_params.collide_with_bodies = true
	ray_params.collision_mask = 15+16
	
	var scan_shape : SphereShape3D = SphereShape3D.new()
	scan_shape.radius = 100.0
	
	var hurtbox_scanner : HurtBoxScanner = HurtBoxScanner.new()
	hurtbox_scanner.scan_only_in_camera_frustum = false
	var closest_hurtbox : HurtBox = hurtbox_scanner.get_closest_hurtbox_to_position(spawn_transform.origin, direct_space_state, scan_shape, spawn_transform, 16)
	
	print(closest_hurtbox.get_parent_node_3d())
	
	global_position = spawn_transform.origin + (-atk_info.instigator.global_basis.z * 0.6)
	
	if closest_hurtbox != null:
		var direction = global_position.direction_to(closest_hurtbox.global_position)
		var flat_dir = Vector3(direction.x ,0.0, direction.z).normalized()
		
		atk_info.instigator.global_basis = Basis.looking_at(flat_dir)
		global_basis = Basis.looking_at(direction)
