class_name SubArea extends Node

@export var spawn_point : Node3D

func get_spawn_point_transform() -> Transform3D:
	return spawn_point.global_transform.orthonormalized()
