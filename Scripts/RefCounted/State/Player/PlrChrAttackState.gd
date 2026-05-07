class_name PlrAttackState extends PlrCharacterState

func on_enter() -> void:
	if character is CombatCharacter:
		input_events.dash_input.connect(character.dodge_dash)
		
		character.move_dir = Vector3(0.0,0.0,0.0)
		
		var combat_chr : CombatCharacter = character as CombatCharacter
		combat_chr.primary_attack()
