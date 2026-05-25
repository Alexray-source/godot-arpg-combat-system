class_name CharacterAirState extends CharacterState

var smoothed_move_dir : Vector3
var up_velocity : Vector3

var momentum_drag : float = 1.2
var physics_velocity : Vector3

func on_enter() -> void:
	smoothed_move_dir = character.move_dir
	up_velocity = character.velocity * character.up_direction
	#character.move_velocity = character.velocity - up_velocity
	
	physics_velocity = character.velocity - up_velocity - character.move_velocity
	#character.up_velocity = Vector3.ZERO

func state_physics_process(delta : float) -> void:
	var velocity_xz_plane : Vector3 = Vector3(character.velocity.x, 0.0, character.velocity.z)
	
	if velocity_xz_plane.length() > 0.0:
		character.global_basis = Basis.looking_at(velocity_xz_plane, character.up_direction)
		
	var move_dir_xz_plane = Vector3(character.move_dir.x, 0.0, character.move_dir.z)
	smoothed_move_dir = smoothed_move_dir.lerp(move_dir_xz_plane, delta * 10.0).normalized()
	
	character.move_velocity = character.move_velocity.lerp(smoothed_move_dir * character.move_speed, delta * 7.0)
	
	up_velocity = character.calculate_gravity_force(up_velocity, delta)
	
	physics_velocity = physics_velocity.lerp(Vector3.ZERO, delta * momentum_drag)
	
	character.velocity = up_velocity + character.move_velocity + physics_velocity

	
	character.move_and_slide()
