class_name SceneAttackRepeater extends SceneAttackTransformer

@export var count : int = 2
@export var interval : float = 0.5
@export var scene_attack_transformer : SceneAttackTransformer

func spawn_with_modified_transform(spawn_function : Callable, original_transform : Transform3D) -> void:
	for i in range(count):
		scene_attack_transformer.spawn_with_modified_transform(spawn_function, original_transform)
		
		var scene_tree : SceneTree = Engine.get_main_loop()
		await scene_tree.create_timer(interval).timeout
