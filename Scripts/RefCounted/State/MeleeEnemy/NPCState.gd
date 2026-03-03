class_name EnemyNPCState extends State

var target : CombatCharacter
var character : CombatCharacter

func get_closest_combat_enemy(scan_radius : float) -> CombatCharacter:
	var scan_shape = SphereShape3D.new()
	scan_shape.radius = scan_radius
	
	var closest_dist : float = scan_shape.radius
	
	var hurtbox_scanner : HurtBoxScanner = HurtBoxScanner.new()
	var nearby_hurtboxes : Array[HurtBox] = hurtbox_scanner.get_nearby_hurtboxes_from_position(character.get_world_3d().direct_space_state, scan_shape, character.global_transform, character.chr_layer.get_enemy_layer())
	
	for nearby_hurtbox in nearby_hurtboxes:
		var hurtbox_distance_to_chr : float = (nearby_hurtbox.global_position - character.global_position).length()
		
		##If hurtbox is not closer than already closest detected distance, skip for loop iteration
		if hurtbox_distance_to_chr >= closest_dist:
			continue
			
		closest_dist = hurtbox_distance_to_chr
		
		if nearby_hurtbox.get_parent_node_3d() is CombatCharacter:
			return nearby_hurtbox.get_parent_node_3d()
	
	return null
