class_name GenericSceneAttack extends Attack

var scene : PackedScene
var local_spawn_offset : Vector3

func attack(instigator : Node3D, _atk_layer : int, dmg : int, atk_type : AtkInfo.AtkType, attack_dir : Vector3, _intended_target : Node3D = null):
	var spawn_pos : Vector3 = instigator.global_position + (instigator.global_basis.orthonormalized() * local_spawn_offset)
	var spawn_basis : Basis = Basis.looking_at(attack_dir)
	
	var scene_instance : SceneAttackInstance = scene.instantiate() as SceneAttackInstance
	
	scene_instance.spawn_transform = Transform3D(spawn_basis, spawn_pos)
	scene_instance.atk_info = AtkInfo.new(dmg, atk_type, instigator, attack_dir, _intended_target)
	instigator.get_parent_node_3d().add_child(scene_instance)
	scene_instance.global_transform = scene_instance.spawn_transform 
	scene_instance.reset_physics_interpolation()
	
