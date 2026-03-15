class_name CharacterPrimaryAttackState extends CharacterState

func on_enter() -> void:
	if character is CombatCharacter:
		character.move_dir = Vector3(0.0,0.0,0.0)
		character.velocity = Vector3(0.0,0.0,0.0)
		
		var combat_chr : CombatCharacter = character as CombatCharacter
		#combat_chr.primary_attack_component.action()
		combat_chr.character_abilities.perform_ability("primary_atk")

func state_physics_process(_delta : float) -> void:
	character.move_and_collide(character.velocity * _delta)
