class_name CharacterAirState extends CharacterState

var smoothed_move_dir : Vector3
var up_velocity : Vector3

func on_enter() -> void:
	smoothed_move_dir = character.move_dir
	up_velocity = character.velocity * character.up_direction
	#character.up_velocity = Vector3.ZERO

func state_physics_process(delta : float) -> void:
	var velocity_xz_plane : Vector3 = Vector3(character.velocity.x, 0.0, character.velocity.z)
	
	if velocity_xz_plane.length() > 0.0:
		character.global_basis = Basis.looking_at(velocity_xz_plane, character.up_direction)
		
	var move_dir_xz_plane = Vector3(character.move_dir.x, 0.0, character.move_dir.z)
	smoothed_move_dir = smoothed_move_dir.lerp(move_dir_xz_plane, delta * 10.0).normalized()
	
	character.move_velocity = smoothed_move_dir * character.move_speed
	
	#print(character.velocity + character.move_velocity)
	up_velocity = character.calculate_gravity_force(up_velocity, delta)
	
	character.velocity = up_velocity + character.move_velocity
	#character.velocity = up_velocity
	#print(character.velocity)
	#if character.move_dir.length() > 0.0:
		#character.move_velocity = smoothed_move_dir * character.move_speed 
		#character.velocity = character.move_velocity + up_velocity
	#else:
		#character.velocity = up_velocity

	
	character.move_and_slide()
