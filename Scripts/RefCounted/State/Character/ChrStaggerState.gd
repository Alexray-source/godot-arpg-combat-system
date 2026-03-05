class_name ChrStaggerState extends CharacterState

var stagger_time : float = 0.0

func on_enter() -> void:
	stagger_time = 0.0
	if character is CombatCharacter:
		character.stagger()

func on_exit() -> void:
	stagger_time = 0.0

func state_physics_process(_delta : float) -> void:
	if stagger_time < 0.7:
		stagger_time += _delta
		character.move_and_collide(character.velocity * _delta)
		
		if stagger_time >= 0.7:
			state_end.emit()
