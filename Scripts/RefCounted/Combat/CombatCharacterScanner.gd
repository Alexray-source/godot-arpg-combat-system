class_name CombatCharacterScanner extends Body3DScanner

var scan_only_in_camera_frustum : bool = false
var blacklist : Array[Node3D]

func get_closest_character_to_position(origin : Vector3, direct_space_state, hit_shape, hitbox_transform, scan_mask):
	var results = scan(direct_space_state, hit_shape, hitbox_transform, scan_mask)
	var closest_character : CombatCharacter = null
	var closest_distance : float = 10000.0
	
	for result in results:
		if result.get("collider") is CombatCharacter:
			var found_character : CombatCharacter = result.get("collider")
			
			var camera_requirements = ((scan_only_in_camera_frustum == true and found_character.get_viewport().get_camera_3d().is_position_in_frustum(found_character.global_position)) or scan_only_in_camera_frustum == false)
			
			if camera_requirements == true and blacklist.find(found_character) == -1 and (found_character.global_position - origin).length() < closest_distance:
				closest_character = found_character
	
	return closest_character
