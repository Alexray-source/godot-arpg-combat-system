class_name CharacterDashState extends CharacterState

var dash_power : float = 35.0

func on_enter() -> void:
	if character is CombatCharacter:
		character.dash(dash_power, 0.2, character.move_dir)

func state_physics_process(_delta : float) -> void:
	character.move_and_collide(character.velocity * _delta)
