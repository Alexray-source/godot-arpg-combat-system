class_name CharacterAirState extends CharacterState

func state_physics_process(delta : float) -> void:
	character.up_velocity = character.velocity * -character.GRAVITY_DIR
	var gravity_acceleration : Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity") * character.GRAVITY_DIR * character.gravity_scale
	var gravity_velocity : Vector3 = (gravity_acceleration * delta).limit_length(20.0)
		
	character.up_velocity += gravity_velocity

	var velocity_xz_plane : Vector3 = Vector3(character.velocity.x, 0.0, character.velocity.z)
	
	if velocity_xz_plane.length() > 0.0:
		character.global_basis = Basis.looking_at(velocity_xz_plane, -character.GRAVITY_DIR)
	
	
	if character.move_dir.length() > 0.0:
		character.move_velocity = character.move_dir.normalized() * character.move_speed * delta * 10.0
		character.velocity = character.move_velocity + character.up_velocity
	else:
		character.velocity = character.up_velocity

	
	character.move_and_slide()
