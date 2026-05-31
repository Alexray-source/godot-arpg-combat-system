class_name ProjectileHit extends Resource

func on_hit(intersected_collider : Node3D, atk_info : AtkInfo):
	if intersected_collider is HurtBox:
		intersected_collider.hit.emit(atk_info)
