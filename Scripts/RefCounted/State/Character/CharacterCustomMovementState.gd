class_name CharacterCustomMovementState extends CharacterState

func state_physics_process(_delta : float) -> void:
	character.move_and_collide(character.velocity * _delta)
	#character.move_and_slide()
