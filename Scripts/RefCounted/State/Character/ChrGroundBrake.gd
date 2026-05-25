class_name CharacterGroundBrakeState extends CharacterState

var smoothed_move_dir : Vector3
var _time : float
var _time_stop_brake_threshold : float

func on_enter() -> void:
	_time = 0.0
	smoothed_move_dir = Vector3(character.move_dir.x, 0.0, character.move_dir.z)
	_time_stop_brake_threshold = character.velocity.length() * 0.1

func state_physics_process(delta : float) -> void:
	#_time += delta
	
	if character.velocity.length() < 2.0:
		state_end.emit()
	
	var up_velocity = Vector3(0.0,-0.1,0.0)
	character.move_velocity = character.move_velocity.lerp(Vector3.ZERO, delta * 5.0)

	if character.move_velocity.length() > 0.0:
		character.global_basis = Basis.looking_at(character.move_velocity, character.up_direction)
	
	character.velocity = up_velocity + character.move_velocity
	character.move_and_slide()
