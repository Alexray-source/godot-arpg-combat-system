class_name ChrKnockbackState extends CharacterState

var knockback_dir : Vector3
var knockback_speed : float = 8.0

func on_enter() -> void:
	character.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	
	character.is_on_floor_changed.connect(on_floor_changed)
	if character is CombatCharacter:
		#character.knockback()
		#knockback_dir = character.global_basis.z
		character.velocity = (knockback_dir * knockback_speed)
		
		if knockback_speed <= 20.0:
			character.velocity.y = 15.0
		else:
			on_floor_changed(character.is_on_floor())
		character.move_and_slide()
		

func on_floor_changed(floored : bool):
	if floored == true:
		state_end.emit()

func on_exit() -> void:
	character.velocity = -knockback_dir
	if character.is_on_floor_changed.is_connected(on_floor_changed) == true:
		character.is_on_floor_changed.disconnect(on_floor_changed)

func state_physics_process(delta : float) -> void:
	character.velocity = character.calculate_gravity_force(character.velocity, delta)
	character.move_and_slide()
