class_name AnimationAttack extends AttackComponent

@export var targeting_range : float = 10.0
@export var animations : Array[String]
@export var anim_player : AnimationPlayer
@export var dmg : int = 10
@export var atk_type : AtkInfo.AtkType = AtkInfo.AtkType.MELEE
@export var attack : Attack

var animation_chainer : AnimationChainer
var hurtbox_scanner : HurtBoxScanner

var target_scan_shape : SphereShape3D

func _ready() -> void:
	hurtbox_scanner = HurtBoxScanner.new()
	
	target_scan_shape = SphereShape3D.new()
	target_scan_shape.radius = targeting_range
	
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
	attack.attack(character, character.chr_layer.get_enemy_layer(), dmg, atk_type)
