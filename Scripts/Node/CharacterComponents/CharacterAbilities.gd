class_name CharacterAbilities extends Node

@export var anim_tree : AnimationTree
@export var character : BaseCharacter
@export var abilities_data : Dictionary[StringName, AbilityData]
var abilities : Dictionary[StringName, AbilityComponent]
var chr_layer : CharacterLayer
var target_override : Node3D

signal ability_finished

func setup() -> void:
	for ability_key in abilities_data:
		var ability_data : AbilityData = abilities_data[ability_key]
		
		var ability_component = ability_data.create_ability_component()
		ability_component.character = character
		ability_component.anim_tree = anim_tree
		ability_component.chr_layer = chr_layer
		ability_component.setup()
		
		ability_component.ability_finished.connect(func ():
			ability_finished.emit()
		)
		
		abilities.set(ability_key, ability_component)

func perform_ability(ability_key : StringName):
	var ability : AbilityComponent = abilities.get(ability_key)
	
	if ability != null:
		#print(target_override)
		ability.target_override = target_override
		ability._action()

func ability_animation_event(ability_key : StringName):
	var ability : AbilityComponent = abilities.get(ability_key)
	
	if ability != null:
		ability._ability_event()

func _physics_process(delta: float) -> void:
	for ability_key in abilities:
		var ability : AbilityComponent = abilities.get(ability_key)
		ability.physics_process(delta)
