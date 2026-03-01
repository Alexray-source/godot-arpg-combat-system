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
var atk_dir : Vector3

func _init(_dmg : int, _atk_type : AtkType, _instigator : Node3D = null, _atk_dir : Vector3 = Vector3.ZERO) -> void:
	dmg = _dmg
	atk_type = _atk_type
	instigator = _instigator
	atk_dir = _atk_dir
