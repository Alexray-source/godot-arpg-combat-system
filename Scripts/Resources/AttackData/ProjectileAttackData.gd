class_name ProjectileAttackData extends AttackData

@export var projectile_scene : PackedScene
@export var projectile_origin_path : NodePath

func create_attack() -> Attack:
	var attack = ProjectileAttack.new()
	attack.projectile_scene = projectile_scene
	attack.projectile_origin_path = projectile_origin_path
	
	return attack
