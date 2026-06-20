class_name HurtBoxScanner extends Area3DScanner

var blacklist : Array[HurtBox] = []
var scan_only_in_camera_frustum : bool = false

func get_closest_hurtbox_to_position(origin : Vector3, direct_space_state, hit_shape, hitbox_transform, scan_mask):
	var results = scan(direct_space_state, hit_shape, hitbox_transform, scan_mask)
	var closest_hurtbox : HurtBox = null
	var closest_distance : float = INF
	
	for result in results:
		if result.get("collider") is HurtBox:
			var found_hurtbox : HurtBox = result.get("collider")
			
			var camera_requirements = ((scan_only_in_camera_frustum == true and found_hurtbox.get_viewport().get_camera_3d().is_position_in_frustum(found_hurtbox.global_position)) or scan_only_in_camera_frustum == false)
			
			var distance = (found_hurtbox.global_position - origin).length()
			
			if camera_requirements == true and blacklist.has(found_hurtbox) == false and distance < closest_distance:
				closest_distance = distance
				closest_hurtbox = found_hurtbox
	
	return closest_hurtbox

func get_nearby_hurtboxes_from_position(direct_space_state, hit_shape, hitbox_transform, scan_mask):
	var results = scan(direct_space_state, hit_shape, hitbox_transform, scan_mask)
	var hurtboxes_found : Array[HurtBox]
	
	for result in results:
		if result.get("collider") is HurtBox and blacklist.find(result.get("collider")) == -1:
			hurtboxes_found.append(result.get("collider"))
	
	return hurtboxes_found
