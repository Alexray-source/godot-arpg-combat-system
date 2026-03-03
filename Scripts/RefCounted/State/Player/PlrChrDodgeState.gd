class_name PlrDodgeState extends PlrCharacterState

func on_enter() -> void:
	if character is CombatCharacter:
		var combat_chr : CombatCharacter = character as CombatCharacter
		combat_chr.dodge_dash()
