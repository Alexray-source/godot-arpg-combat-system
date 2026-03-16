class_name ProjectileAttack extends Attack

var projectile_scene : PackedScene
var projectile_origin_path : NodePath

func attack(instigator : Node3D, atk_layer : int, dmg : int, atk_type : AtkInfo.AtkType, attack_dir : Vector3):
	var projectile : Projectile = projectile_scene.instantiate() as Projectile
	projectile.atk_info = AtkInfo.new(dmg, atk_type, instigator, -instigator.global_basis.z)

	var projectile_origin : Node3D = instigator.get_node(projectile_origin_path)

	instigator.get_parent_node_3d().add_child(projectile)
	projectile.global_position = projectile_origin.global_position + (-instigator.global_basis.z * 0.6)
	projectile.global_basis = Basis.looking_at(attack_dir)
	projectile.reset_physics_interpolation()
	
