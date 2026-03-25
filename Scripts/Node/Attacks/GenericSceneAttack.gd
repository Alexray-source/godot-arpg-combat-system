class_name GenericSceneAttack extends Attack

var scene : PackedScene
var local_spawn_offset : Vector3

func attack(instigator : Node3D, _atk_layer : int, dmg : int, atk_type : AtkInfo.AtkType, attack_dir : Vector3):
	var scene_instance : SceneAttackInstance = scene.instantiate() as SceneAttackInstance
	
	scene_instance.atk_info = AtkInfo.new(dmg, atk_type, instigator, attack_dir)
	instigator.get_parent_node_3d().add_child(scene_instance)
	scene_instance.global_position = instigator.global_position + (instigator.global_basis.orthonormalized() * local_spawn_offset)
	scene_instance.global_basis = Basis.looking_at(attack_dir)
	scene_instance.reset_physics_interpolation()
	
