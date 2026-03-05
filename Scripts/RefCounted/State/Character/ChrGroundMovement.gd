class_name CharacterGroundState extends CharacterState

var smoothed_move_dir : Vector3

func on_enter() -> void:
	smoothed_move_dir = Vector3(character.move_dir.x, 0.0, character.move_dir.z)

func state_physics_process(delta : float) -> void:
	var move_dir_xz_plane = Vector3(character.move_dir.x, 0.0, character.move_dir.z)
	smoothed_move_dir = smoothed_move_dir.lerp(move_dir_xz_plane, delta * 14.0).normalized()
	
	if character.move_dir.length() > 0.0:
		character.move_velocity = smoothed_move_dir * character.move_speed * delta * 10.0
	else:
		character.move_velocity = Vector3.ZERO
	
	character.up_velocity = Vector3(0.0,-0.1,0.0)
	
	var velocity_xz_plane : Vector3 = Vector3(character.velocity.x, 0.0, character.velocity.z)

	if velocity_xz_plane.length() > 0.0:
		character.global_basis = Basis.looking_at(velocity_xz_plane, -character.GRAVITY_DIR)
	
	character.velocity = character.up_velocity + character.move_velocity
	character.move_and_slide()
