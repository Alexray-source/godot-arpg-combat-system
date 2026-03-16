class_name PlrSpecialAtkState extends PlrCharacterState

@export var special_atk_index : int = 1

func on_enter() -> void:
	if character is CombatCharacter:
		character.move_dir = Vector3(0.0,0.0,0.0)
		
		var combat_chr : CombatCharacter = character as CombatCharacter
		combat_chr.perform_ability_slot(special_atk_index)
