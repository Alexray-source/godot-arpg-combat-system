extends SceneAttackInstance

@export var scene_attack : PackedScene
@export var scene_transformer : SceneAttackTransformer
@export var spawn_at_target : bool = false

func _ready() -> void:
	super()
	
	if spawn_at_target == true and atk_info.intended_target != null:
		global_transform = atk_info.intended_target.global_transform.orthonormalized()
		spawn_transform = global_transform
	
	scene_transformer.spawn_with_modified_transform(spawn_pillar, spawn_transform)

func spawn_pillar(target_transform : Transform3D):
	var pillar : SceneAttackInstance = scene_attack.instantiate()
	pillar.atk_info = atk_info
	pillar.spawn_transform = target_transform
	
	add_child(pillar)
