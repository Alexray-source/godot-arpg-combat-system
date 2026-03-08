class_name ChrCamArm extends SpringArm3D

@export var target : Node3D
@export var target_offset_pos : Vector3
@export var pos_follow_speed : float = 15.0

func _physics_process(delta: float) -> void:
	if target == null:
		return
	
	global_position = global_position.lerp(target.global_position + target_offset_pos, clamp(delta * pos_follow_speed, 0.0, 1.0))
