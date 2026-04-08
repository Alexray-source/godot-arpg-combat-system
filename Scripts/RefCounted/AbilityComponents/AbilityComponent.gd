@abstract class_name AbilityComponent extends RefCounted

signal ability_finished
signal ability_hit(hurtboxes_hit : Array[HurtBox])

var chr_layer : CharacterLayer
var character : Node3D
var anim_tree : AnimationTree
var target_override : Node3D

func setup() -> void:
	pass

func physics_process(_delta : float) -> void:
	pass

@abstract func action() -> void
@abstract func ability_event() -> void
