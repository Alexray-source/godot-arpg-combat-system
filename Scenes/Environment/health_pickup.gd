extends Node3D

@export var heal_amount : int = 15
@export var chr_detector : CharacterDetector

func _ready() -> void:
	chr_detector.chr_entered.connect(on_chr_entered)

func on_chr_entered(entered_character : BaseCharacter):
	if entered_character is CombatCharacter:
		entered_character.heal(heal_amount)
		queue_free()
