class_name HurtBoxScanner extends Area3DScanner

func get_closest_hurtbox_to_position(origin : Vector3, direct_space_state, hit_shape, hitbox_transform, scan_mask):
	var results = scan(direct_space_state, hit_shape, hitbox_transform, scan_mask)
	var closest_hurtbox : HurtBox = null
	var closest_distance : float = 10000.0
	
	for result in results:
		if result.get("collider") is HurtBox:
			var found_hurtbox : HurtBox = result.get("collider")
			if (found_hurtbox.global_position - origin).length() < closest_distance:
				closest_hurtbox = found_hurtbox
	
	return closest_hurtbox
