class_name CharacterDashState extends CharacterState

var dash_power : float = 25.0

func on_enter() -> void:
	if character is CombatCharacter:
		character.invincible = true
		character.global_basis = Basis.looking_at(Vector3(character.move_dir.x, 0.0, character.move_dir.z))
		character.dash(dash_power, 0.2, character.move_dir)

func on_exit() -> void:
	if character is CombatCharacter:
		character.invincible = false

func state_physics_process(_delta : float) -> void:
	character.move_and_collide(character.velocity * _delta)
