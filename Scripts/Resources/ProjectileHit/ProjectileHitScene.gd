class_name ProjectileHitScene extends ProjectileHit

@export var scene_attack : PackedScene

func on_hit(intersected_collider : Node3D, atk_info : AtkInfo):
	if intersected_collider is HurtBox:
		var spawned_scene : SceneAttackInstance = scene_attack.instantiate()
		spawned_scene.atk_info = atk_info
		spawned_scene.spawn_transform = intersected_collider.global_transform
		
		intersected_collider.get_tree().current_scene.add_child(spawned_scene)
