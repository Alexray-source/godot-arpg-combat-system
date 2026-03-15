@abstract class_name AbilityComponent extends RefCounted

signal ability_finished

var chr_layer : CharacterLayer
var character : BaseCharacter
var anim_player : AnimationPlayer

func setup() -> void:
	pass

@abstract func _action() -> void
@abstract func _ability_event() -> void
