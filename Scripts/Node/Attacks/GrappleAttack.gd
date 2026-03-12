class_name GrappleAttack extends Attack

@export var attack_data : AoeAttackData

func attack(instigator : Node3D, atk_layer : int, dmg : int, atk_type : AtkInfo.AtkType):
	var aoe_grapple = AoeGrapple.new()
	
	aoe_grapple.instigator = instigator
	aoe_grapple.scan_only_in_camera_frustum = true
	aoe_grapple.direct_space_state = instigator.get_world_3d().direct_space_state
	aoe_grapple.hit_shape = attack_data.hit_shape
	
	aoe_grapple.scan_mask = atk_layer
	aoe_grapple.hitbox_transform = Transform3D(instigator.global_basis.orthonormalized(), instigator.global_position + (instigator.global_basis.orthonormalized() * attack_data.local_offset))
	
	aoe_grapple.attempt_grapple_to_closest_object()
