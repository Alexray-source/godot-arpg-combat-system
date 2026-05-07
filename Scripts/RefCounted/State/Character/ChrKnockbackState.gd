class_name ChrKnockbackState extends CharacterState

var up_velocity : Vector3
var knockback_dir : Vector3
var knockback_speed : float = 580.0

func on_enter() -> void:
	character.is_on_floor_changed.connect(on_floor_changed)
	
	if character is CombatCharacter:
		#character.knockback()
		knockback_dir = -character.global_basis.z
		character.velocity.y = 15.0
		character.move_and_slide()
		#character.up_velocity = Vector3(0.0,30.0,0.0)

func on_floor_changed(floored : bool):
	if floored == true:
		state_end.emit()

func on_exit() -> void:
	character.velocity = knockback_dir
	up_velocity = Vector3.ZERO
	if character.is_on_floor_changed.is_connected(on_floor_changed) == true:
		character.is_on_floor_changed.disconnect(on_floor_changed)

func state_physics_process(delta : float) -> void:
	up_velocity = character.apply_gravity_force(up_velocity, delta)
	character.velocity = (-knockback_dir * knockback_speed * delta) + up_velocity
	#character.move_and_slide()
	character.move_and_slide()
