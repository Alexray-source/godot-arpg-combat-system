class_name SceneAttackInstance extends Node3D

var atk_info : AtkInfo
var spawn_transform : Transform3D

@export var attack_indicator : String
@export var life_time : float = 5.0

func _ready() -> void:
	global_transform = spawn_transform
	reset_physics_interpolation()
	
	get_tree().create_timer(life_time).timeout.connect(queue_free)

func show_indicator(target_transform : Transform3D):
	GlobalSignals.spawn_vfx.emit(attack_indicator, target_transform.orthonormalized())
