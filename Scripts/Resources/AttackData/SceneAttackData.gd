class_name SceneAttackData extends AttackData

@export var scene : PackedScene
@export var local_spawn_offset : Vector3

func create_attack() -> Attack:
	var attack = GenericSceneAttack.new()
	attack.local_spawn_offset = local_spawn_offset
	attack.scene = scene
	
	return attack
