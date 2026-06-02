extends Node3D

var _camera : Camera3D

func _ready() -> void:
	_camera = get_viewport().get_camera_3d()

func _process(_delta: float) -> void:
	global_basis = Basis.looking_at(global_position.direction_to(_camera.global_position))
