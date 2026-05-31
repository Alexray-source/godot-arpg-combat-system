class_name SceneAttackRandomPosition extends SceneAttackTransformer

@export var horizontal_randomness : float = 2.0
@export var vertical_randomness : float = 2.0


func spawn_with_modified_transform(spawn_function : Callable, original_transform : Transform3D) -> void:
	var random_pos = original_transform.origin + Vector3(randf_range(-horizontal_randomness, horizontal_randomness), randf_range(-vertical_randomness, vertical_randomness), randf_range(-horizontal_randomness, horizontal_randomness))
	
	spawn_function.call(Transform3D(original_transform.basis, random_pos))
