class_name AoeAttackData extends AttackData

@export var hit_shape : Shape3D
@export var local_offset : Vector3
@export var debug : bool = false

func create_attack() -> Attack:
	var attack = AoeAttack.new()
	attack.hit_shape = hit_shape
	attack.local_offset = local_offset
	attack.debug = debug
	
	return attack
