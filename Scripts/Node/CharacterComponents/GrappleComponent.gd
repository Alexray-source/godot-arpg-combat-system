class_name GrappleComponent extends AbilityComponent

@export var attack_data : AoeAttackData
@export var targeting_range : float = 10.0
@export var animations : Array[String]
@export var should_target_characters : bool = false

var animation_chainer : AnimationChainer
var aoe_grapple : AoeGrapple

func _init(_character : BaseCharacter, _anim_player : AnimationPlayer) -> void:
	aoe_grapple = AoeGrapple.new()
	aoe_grapple.hit_shape = attack_data.hit_shape
	aoe_grapple.direct_space_state = character.get_world_3d().direct_space_state
	aoe_grapple.grapple_finished.connect(on_grapple_finished)
	
	animation_chainer = AnimationChainer.new()
	animation_chainer.anim_player = _anim_player
	animation_chainer.animations = animations
	animation_chainer.setup()

func _physics_process(delta: float) -> void:
	aoe_grapple.physics_process(delta)

func on_grapple_finished():
	ability_finished.emit()

func action() -> void:
	aoe_grapple.instigator = character
	
	if should_target_characters == true:
		aoe_grapple.scan_mask = 2 + chr_layer.get_enemy_layer()
	else:
		aoe_grapple.scan_mask = 1
	
	aoe_grapple.scan_only_in_camera_frustum = true
	aoe_grapple.hitbox_transform = Transform3D(character.global_basis.orthonormalized(), character.global_position + (character.global_basis.orthonormalized() * attack_data.local_offset))
	
	var closest_grapple_object = aoe_grapple.get_closest_grapple_object()
	if closest_grapple_object != null:
		var chr_pos_xz_plane : Vector3 = Vector3(character.global_position.x, 0.0, character.global_position.z)
		var closest_hurtbox_pos_xz_plane : Vector3 = Vector3(closest_grapple_object.global_position.x, 0.0, closest_grapple_object.global_position.z)
		
		character.global_basis = Basis.looking_at((closest_hurtbox_pos_xz_plane - chr_pos_xz_plane).normalized(), Vector3.UP)
	#print(closest_grapple_object)
	if closest_grapple_object == null:
		on_grapple_finished()
	else:
		animation_chainer.resume_chain()

	
func ability_event() -> void:
	aoe_grapple.hitbox_transform = Transform3D(character.global_basis.orthonormalized(), character.global_position + (character.global_basis.orthonormalized() * attack_data.local_offset))
	
	aoe_grapple.attempt_grapple_to_closest_object()
