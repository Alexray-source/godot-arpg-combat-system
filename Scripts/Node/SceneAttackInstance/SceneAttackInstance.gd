class_name SceneAttackInstance extends Node3D

var atk_info : AtkInfo
var spawn_transform : Transform3D

@export var attack_indicator : String

func _ready() -> void:
	global_transform = spawn_transform
	reset_physics_interpolation()

func show_indicator(target_transform : Transform3D):
	GlobalSignals.spawn_vfx.emit(attack_indicator, target_transform.orthonormalized())
