@abstract class_name AttackComponent extends CharacterComponent

signal atk_finished

@export var chr_layer : CharacterLayer

@abstract func action() -> void
@abstract func attack_event() -> void
