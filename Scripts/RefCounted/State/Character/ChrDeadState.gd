class_name CharacterDeadState extends CharacterState

func on_enter() -> void:
	character.get_tree().create_timer(1.0).timeout.connect(state_end.emit)
