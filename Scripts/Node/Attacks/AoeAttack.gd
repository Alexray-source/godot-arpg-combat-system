class_name AoeAttack extends Attack

#@export var attack_data : AoeAttackData
var hit_shape : Shape3D
var local_offset : Vector3
var debug : bool = false

func attack(instigator : Node3D, atk_layer : int, dmg : int, atk_type : AtkInfo.AtkType, _atk_dir : Vector3, optional_target : Node3D = null):
	var melee_hitbox = AoeHitbox.new()
	melee_hitbox.direct_space_state = instigator.get_world_3d().direct_space_state
	melee_hitbox.hit_shape = hit_shape
	
	melee_hitbox.scan_mask = atk_layer
	melee_hitbox.atk_info = AtkInfo.new(dmg, atk_type, instigator, -instigator.global_basis.z.normalized())
	melee_hitbox.hitbox_transform = Transform3D(instigator.global_basis.orthonormalized(), instigator.global_position + (instigator.global_basis.orthonormalized() * local_offset))
	
	if debug == true:
		var mesh = BoxMesh.new()
		mesh.size = hit_shape.size
		
		var mesh_inst : MeshInstance3D = MeshInstance3D.new()
		mesh_inst.mesh = mesh
		mesh_inst.top_level = true
		instigator.add_child(mesh_inst)
		
		mesh_inst.global_transform = melee_hitbox.hitbox_transform
	
	melee_hitbox.hurtboxes_hit.connect(hurtboxes_hit.emit, CONNECT_ONE_SHOT)
	melee_hitbox.attack()
