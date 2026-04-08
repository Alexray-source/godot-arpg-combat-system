class_name PlrSpecialAtkState extends PlrCharacterState

var ability_key : String

func on_enter() -> void:
	if character is CombatCharacter:
		character.move_dir = Vector3(0.0,0.0,0.0)
		
		var combat_chr : CombatCharacter = character as CombatCharacter
		combat_chr.perform_ability(ability_key)
