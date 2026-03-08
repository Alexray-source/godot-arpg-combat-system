class_name MeleeAttack extends AttackComponent

@export var targeting_range : float = 10.0
@export var animations : Array[String]
@export var anim_player : AnimationPlayer
@export var hit_shape : Shape3D
@export var local_offset : Vector3
@export var dmg : int = 10
@export var atk_type : AtkInfo.AtkType = AtkInfo.AtkType.MELEE

var animation_chainer : AnimationChainer
var melee_hitbox : MeleeHitbox
var hurtbox_scanner : HurtBoxScanner

var target_scan_shape : SphereShape3D

func _ready() -> void:
	hurtbox_scanner = HurtBoxScanner.new()
	
	target_scan_shape = SphereShape3D.new()
	target_scan_shape.radius = targeting_range
	
	melee_hitbox = MeleeHitbox.new()
	melee_hitbox.direct_space_state = get_viewport().world_3d.direct_space_state
	melee_hitbox.hit_shape = hit_shape
	
	animation_chainer = AnimationChainer.new()
	animation_chainer.anim_player = anim_player
	animation_chainer.animations = animations
	animation_chainer.animation_finished.connect(on_animation_finish)
	animation_chainer.setup()
	
	print(animation_chainer.animations)

func on_animation_finish():
	atk_finished.emit()
	animation_chainer.reset_chain()

func action() -> void:
	var closest_hurtbox = hurtbox_scanner.get_closest_hurtbox_to_position(character.global_position, get_viewport().world_3d.direct_space_state, target_scan_shape, character.global_transform, chr_layer.get_enemy_layer())
	
	if closest_hurtbox != null:
		var chr_pos_xz_plane : Vector3 = Vector3(character.global_position.x, 0.0, character.global_position.z)
		var closest_hurtbox_pos_xz_plane : Vector3 = Vector3(closest_hurtbox.global_position.x, 0.0, closest_hurtbox.global_position.z)
		
		character.global_basis = Basis.looking_at((closest_hurtbox_pos_xz_plane - chr_pos_xz_plane).normalized(), Vector3.UP)
	
	animation_chainer.resume_chain()

func attack_event() -> void:
	melee_hitbox.scan_mask = chr_layer.get_enemy_layer()
	melee_hitbox.atk_info = AtkInfo.new(dmg, atk_type, character, -character.global_basis.z.normalized())
	melee_hitbox.hitbox_transform = Transform3D(character.global_basis.orthonormalized(), character.global_position + (character.global_basis.orthonormalized() * local_offset))
	
	melee_hitbox.attack()
