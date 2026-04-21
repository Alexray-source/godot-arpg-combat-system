class_name CharacterAbilities extends Node

@export var anim_tree : AnimationTree
@export var character : BaseCharacter
@export var abilities_data : Dictionary[StringName, AbilityData]
var _abilities : Dictionary[StringName, AbilityComponent]
var chr_layer : CharacterLayer
var target_override : Node3D

var active_ability : AbilityComponent

signal ability_finished
signal ability_hit(hurtboxes_hit : Array[HurtBox])

func setup() -> void:
	for ability_key in abilities_data:
		create_and_store_ability_component(ability_key)

func reset() -> void:
	_abilities.clear()

func add_ability_data(ability_key : StringName, ability_data : AbilityData):
	abilities_data[ability_key] = ability_data

func interrupt_active_ability():
	if active_ability != null:
		active_ability.cancel()
		active_ability = null

func create_and_store_ability_component(ability_key : StringName):
	var ability_data = abilities_data[ability_key]
	var ability_component = ability_data.create_ability_component()
	ability_component.character = character
	ability_component.anim_tree = anim_tree
	ability_component.chr_layer = chr_layer
	ability_component.setup()
	
	ability_component.ability_finished.connect(on_ability_component_finished)
	ability_component.ability_hit.connect(ability_hit.emit)
	
	_abilities.set(ability_key, ability_component)

func on_ability_component_finished():
	active_ability = null
	ability_finished.emit()

func perform_ability(ability_key : StringName):
	var ability : AbilityComponent = _abilities.get(ability_key)
	
	if ability != null:
		if ability != active_ability:
			interrupt_active_ability()
		#print(target_override)
		ability.target_override = target_override
		ability.action()
		active_ability = ability

func ability_animation_event(ability_key : StringName):
	var ability : AbilityComponent = _abilities.get(ability_key)
	
	if ability != null:
		ability.ability_event()

func _physics_process(delta: float) -> void:
	for ability_key in _abilities:
		var ability : AbilityComponent = _abilities.get(ability_key)
		ability.physics_process(delta)
