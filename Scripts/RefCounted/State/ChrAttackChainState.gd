extends CharacterState

func on_enter() -> void:
	if character is CombatCharacter:
		character.move_dir = Vector3(0.0,0.0,0.0)
		
		var combat_chr : CombatCharacter = character as CombatCharacter
		combat_chr.primary_attack_component.action()

func state_physics_process(_delta : float) -> void:
	character.move_and_slide()
