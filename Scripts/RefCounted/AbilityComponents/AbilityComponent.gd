@abstract class_name AbilityComponent extends RefCounted

@warning_ignore_start("unused_signal")
signal ability_finished
signal ability_hit(hurtboxes_hit : Array[HurtBox])
@warning_ignore_restore("unused_signal")

var chr_layer : CharacterLayer
var character : Node3D
var anim_tree : AnimationTree
var target_override : Node3D

var _interrupted : bool = false

func setup() -> void:
	pass

func physics_process(_delta : float) -> void:
	pass

@abstract func action() -> void
@abstract func ability_event() -> void

func cancel() -> void:
	_interrupted = true
