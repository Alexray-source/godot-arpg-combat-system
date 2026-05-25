class_name CharacterGroundState extends CharacterState

var smoothed_move_dir : Vector3

signal braked

func on_enter() -> void:
	smoothed_move_dir = Vector3(character.move_dir.x, 0.0, character.move_dir.z)
	character.move_velocity = character.velocity

func state_physics_process(delta : float) -> void:
	var move_dir_xz_plane = Vector3(character.move_dir.x, 0.0, character.move_dir.z)
	
	if move_dir_xz_plane.dot(smoothed_move_dir) < -0.4:
		braked.emit()
	
	smoothed_move_dir = smoothed_move_dir.lerp(move_dir_xz_plane, delta * 9.0)
	
	if character.move_dir.is_zero_approx() == false:
		character.move_velocity = character.move_velocity.lerp(smoothed_move_dir.normalized() * character.move_speed, delta * 15.0)
		#character.move_velocity = smoothed_move_dir.normalized() * character.move_speed
	else:
		character.move_velocity = character.move_velocity.lerp(Vector3.ZERO, delta * 3.0)
	
	var up_velocity = Vector3(0.0,-0.1,0.0)
	
	var velocity_xz_plane : Vector3 = Vector3(character.velocity.x, 0.0, character.velocity.z)

	if velocity_xz_plane.is_zero_approx() == false:
		character.global_basis = Basis.looking_at(velocity_xz_plane, character.up_direction)
	
	character.velocity = up_velocity + character.move_velocity
	character.move_and_slide()
