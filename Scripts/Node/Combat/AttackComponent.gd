@abstract class_name AttackComponent extends Node

@export_custom(PROPERTY_HINT_LAYERS_3D_PHYSICS, "") var atk_layer : int = 13
@export var dmg : int = 10
@export var atk_type : AtkInfo.AtkType = AtkInfo.AtkType.DEFAULT
var instigator : Node3D

@abstract func start_attack() -> void
