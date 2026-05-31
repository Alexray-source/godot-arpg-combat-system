class_name ProjectileHitAoe extends ProjectileHit

@export var aoe_range : float = 10.0
@export var aoe_hit_event : ProjectileHit

func on_hit(intersected_collider : Node3D, atk_info : AtkInfo):
	var scan_shape : SphereShape3D = SphereShape3D.new()
	scan_shape.radius = aoe_range
	
	var direct_space_state = intersected_collider.get_world_3d().direct_space_state
	
	var hurtbox_scanner : HurtBoxScanner = HurtBoxScanner.new()
	hurtbox_scanner.scan_only_in_camera_frustum = false
	var nearby_hurtboxes : Array[HurtBox] = hurtbox_scanner.get_nearby_hurtboxes_from_position(direct_space_state, scan_shape, Transform3D
	(Basis.IDENTITY, intersected_collider.global_position), 15+16)
	
	for hurtbox in nearby_hurtboxes:
		aoe_hit_event.on_hit(hurtbox, atk_info)
