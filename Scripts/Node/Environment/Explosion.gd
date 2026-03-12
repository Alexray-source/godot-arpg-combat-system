class_name ExplosionSpawner extends AttackComponent

@export var explosion_origin : Node3D
@export var attack_data : AoeAttackData

var aoe_hitbox : AoeHitbox

func _ready() -> void:
	aoe_hitbox = AoeHitbox.new()
	aoe_hitbox.hit_shape = attack_data.hit_shape
	aoe_hitbox.scan_mask = atk_layer
	aoe_hitbox.atk_dir_from_aoe_center = true

func start_attack() -> void:
	aoe_hitbox.direct_space_state = instigator.get_world_3d().direct_space_state
	aoe_hitbox.atk_info = AtkInfo.new(dmg, atk_type, instigator)
	aoe_hitbox.hitbox_transform = Transform3D(explosion_origin.global_basis.orthonormalized(), explosion_origin.global_position + (explosion_origin.global_basis.orthonormalized() * attack_data.local_offset))
	
	aoe_hitbox.attack()
