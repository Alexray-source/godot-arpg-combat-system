class_name VFXSpawner extends Node

const VFX_DATABASE = preload("res://Resources/VFXDatabase.tres")

func _ready() -> void:
	GlobalSignals.spawn_vfx.connect(on_spawn_vfx)
	GlobalSignals.spawn_vfx_attached.connect(on_spawn_vfx_attached)

func on_spawn_vfx(vfx_key : String, target_transform : Transform3D):
	var vfx_scene : PackedScene = VFX_DATABASE.entries.get(vfx_key)
	if vfx_scene == null:
		return
	
	var vfx_instance : Node3D = vfx_scene.instantiate()
	add_child(vfx_instance)
	vfx_instance.global_transform = target_transform

func on_spawn_vfx_attached(vfx_key : String, parent_node : Node3D):
	var vfx_scene : PackedScene = VFX_DATABASE.entries.get(vfx_key)
	if vfx_scene == null:
		return
	
	var vfx_instance : Node3D = vfx_scene.instantiate()
	parent_node.add_child(vfx_instance)
	vfx_instance.position = Vector3.ZERO
	vfx_instance.basis = Basis.IDENTITY
	print("spawned attached vfx")
