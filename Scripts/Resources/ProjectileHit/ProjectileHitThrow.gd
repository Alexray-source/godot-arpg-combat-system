class_name ProjectileHitThrow extends ProjectileHit

@export var throw_speed : float = 50.0

func on_hit(intersected_collider : Node3D, atk_info : AtkInfo):
	var collider_parent : Node3D = intersected_collider.get_parent_node_3d()
	
	if intersected_collider is HurtBox and collider_parent != null and collider_parent is Throwable:
		#intersected_collider.hit.emit(atk_info)
		var target = atk_info.intended_target
		
		if target != null:
			collider_parent.throw(collider_parent.global_position.direction_to(target.global_position), throw_speed)
