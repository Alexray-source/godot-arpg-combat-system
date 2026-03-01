class_name CharacterSpecialAttackState extends CharacterState

@export var special_atk_index : int = 1

func on_enter() -> void:
	if character is CombatCharacter:
		character.move_dir = Vector3(0.0,0.0,0.0)
		character.velocity = Vector3(0.0,0.0,0.0)
		
		var combat_chr : CombatCharacter = character as CombatCharacter
		combat_chr.get("special_attack" + str(special_atk_index) + "_component").action()

func state_physics_process(_delta : float) -> void:
	character.move_and_collide(character.velocity * _delta)
