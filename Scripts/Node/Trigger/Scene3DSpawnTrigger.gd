class_name Scene3DSpawnTrigger
extends Trigger

@export var target_scene : PackedScene
@export var target_transform_node : Node3D

func execute(_params : Dictionary):
	var instance : Node3D = target_scene.instantiate()
	add_child(instance)
	instance.global_transform = target_transform_node.global_transform.orthonormalized()
