class_name AtkInfo extends RefCounted

enum AtkType {
	DEFAULT,
	MELEE,
	PROJECTILE,
	MASSIVE,
	MASSIVE_PROJECTILE,
	ABILITY,
	DEFLECT
}

var instigator : Node3D
var intended_target : Node3D
var dmg : int
var atk_type : AtkType = AtkType.DEFAULT
var atk_dir : Vector3

func _init(_dmg : int, _atk_type : AtkType, _instigator : Node3D = null, _atk_dir : Vector3 = Vector3.ZERO, _optional_target : Node3D = null) -> void:
	dmg = _dmg
	atk_type = _atk_type
	instigator = _instigator
	atk_dir = _atk_dir
	intended_target = _optional_target
