class_name SceneAttackRow extends SceneAttackTransformer

@export var count : int = 3
@export var gap : float = 10.0

func spawn_with_modified_transform(spawn_function : Callable, original_transform : Transform3D) -> void:
	var spawn_pos = original_transform.origin
	var spawn_look_dir = -original_transform.basis.z
	
	for i in range(count):
		spawn_function.call(Transform3D(original_transform.basis, spawn_pos + (spawn_look_dir * gap * i)))
