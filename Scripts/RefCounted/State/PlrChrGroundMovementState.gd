class_name PlrGroundMovement extends PlrCharacterState

var current_camera : Camera3D

func on_enter() -> void:
	input_events.jump_input.connect(character.jump)
	current_camera = character.get_viewport().get_camera_3d()

func on_exit() -> void:
	if input_events.jump_input.is_connected(character.jump) == true:
		input_events.jump_input.disconnect(character.jump)


func state_physics_process(delta : float) -> void:
	input_events.process(delta)
	
	var flat_right_dir = Vector3(current_camera.global_basis.x.x, 0.0, current_camera.global_basis.x.z)
	var flat_forward_dir = Vector3(current_camera.global_basis.z.x, 0.0, current_camera.global_basis.z.z)
	
	var corrected_basis = Basis(flat_right_dir, Vector3.UP, -flat_forward_dir)
	var relative_input_camera_view : Vector3 = corrected_basis * input_events.move_dir
	character.move_dir = relative_input_camera_view
