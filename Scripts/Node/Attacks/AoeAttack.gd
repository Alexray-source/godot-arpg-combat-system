class_name AoeAttack extends Attack

@export var attack_data : AoeAttackData

func attack(instigator : Node3D, atk_layer : int, dmg : int, atk_type : AtkInfo.AtkType):
	var melee_hitbox = AoeHitbox.new()
	melee_hitbox.direct_space_state = instigator.get_world_3d().direct_space_state
	melee_hitbox.hit_shape = attack_data.hit_shape
	
	melee_hitbox.scan_mask = atk_layer
	melee_hitbox.atk_info = AtkInfo.new(dmg, atk_type, instigator, -instigator.global_basis.z.normalized())
	melee_hitbox.hitbox_transform = Transform3D(instigator.global_basis.orthonormalized(), instigator.global_position + (instigator.global_basis.orthonormalized() * attack_data.local_offset))
	
	melee_hitbox.attack()
