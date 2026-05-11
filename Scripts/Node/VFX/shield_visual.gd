extends Node3D

func _exit_tree() -> void:
	GlobalSignals.spawn_vfx.emit("shield_break", global_transform)
