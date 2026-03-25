@abstract class_name AbilityComponent extends RefCounted

signal ability_finished

var chr_layer : CharacterLayer
var character : Node3D
var anim_tree : AnimationTree
var target_override : Node3D


func setup() -> void:
	pass

func physics_process(delta : float) -> void:
	pass

@abstract func _action() -> void
@abstract func _ability_event() -> void
