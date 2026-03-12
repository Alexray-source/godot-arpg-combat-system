@abstract class_name AbilityComponent extends CharacterComponent

signal ability_finished

@export var chr_layer : CharacterLayer

@abstract func action() -> void
@abstract func ability_event() -> void
