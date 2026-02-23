class_name AtkInfo extends RefCounted

enum AtkType {
	DEFAULT,
	MELEE,
	PROJECTILE,
	MASSIVE,
	ABILITY
}

var instigator : Node3D
var dmg : int
var atk_type : AtkType = AtkType.DEFAULT

func _init(_dmg : int, _atk_type : AtkType, _instigator : Node3D = null) -> void:
	dmg = _dmg
	atk_type = _atk_type
	instigator = _instigator
