class_name ChrStunnedState extends CharacterState

func state_physics_process(_delta : float) -> void:
	character.move_dir = Vector3(0.0,0.0,0.0)
