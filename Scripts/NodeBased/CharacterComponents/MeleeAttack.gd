class_name MeleeAttack extends AttackComponent

@export var targeting_range : float = 10.0
@export var animation_library : String
@export var anim_player : AnimationPlayer
@export var hit_shape : Shape3D
@export var local_offset : Vector3
@export var hostile_mask : int = 1
@export var dmg : int = 10

var animation_chainer : AnimationChainer = AnimationChainer.new()
var melee_hitbox : MeleeHitbox = MeleeHitbox.new()
var hurtbox_scanner : HurtBoxScanner = HurtBoxScanner.new()

var target_scan_shape : SphereShape3D

func _ready() -> void:
	target_scan_shape = SphereShape3D.new()
	target_scan_shape.radius = targeting_range
	
	melee_hitbox.direct_space_state = get_viewport().world_3d.direct_space_state
	melee_hitbox.hit_shape = hit_shape
	melee_hitbox.scan_mask = hostile_mask
	melee_hitbox.atk_info = AtkInfo.new(dmg, AtkInfo.AtkType.MELEE, character)
	melee_hitbox.hitbox_transform = Transform3D(character.global_basis.orthonormalized(), character.global_position + (character.global_basis.orthonormalized() * local_offset))
	
	animation_chainer.anim_player = anim_player
	animation_chainer.attacks_library_name = animation_library
	animation_chainer.animation_finished.connect(on_animation_finish)
	animation_chainer.setup()

func on_animation_finish():
	atk_finished.emit()

func action() -> void:
	var closest_hurtbox = hurtbox_scanner.get_closest_hurtbox_to_position(character.global_position, get_viewport().world_3d.direct_space_state, target_scan_shape, character.global_transform, hostile_mask)
	
	if closest_hurtbox != null:
		var chr_pos_xz_plane : Vector3 = Vector3(character.global_position.x, 0.0, character.global_position.z)
		var closest_hurtbox_pos_xz_plane : Vector3 = Vector3(closest_hurtbox.global_position.x, 0.0, closest_hurtbox.global_position.z)
		
		character.global_basis = Basis.looking_at((closest_hurtbox_pos_xz_plane - chr_pos_xz_plane).normalized(), Vector3.UP)
	
	animation_chainer.resume_chain()

func attack() -> void:
	melee_hitbox.attack()
