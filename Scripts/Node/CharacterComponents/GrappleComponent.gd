class_name GrappleComponent extends AbilityComponent

var targeting_range : float = 20.0
var animation_node_name : String
var oneshot_node_name : String
var animations : Array[String]
var should_target_characters : bool = false

var _animation_chainer : AnimationChainer
var _aoe_grapple : AoeGrapple
var _scan_shape : SphereShape3D

func setup() -> void:
	_scan_shape = SphereShape3D.new()
	_scan_shape.radius = targeting_range
	
	_aoe_grapple = AoeGrapple.new()
	_aoe_grapple.instigator = character
	_aoe_grapple.hit_shape = _scan_shape
	_aoe_grapple.direct_space_state = character.get_world_3d().direct_space_state
	_aoe_grapple.grapple_finished.connect(on_grapple_finished)
	_aoe_grapple.setup()
	
	_animation_chainer = AnimationChainer.new()
	_animation_chainer.anim_tree = anim_tree
	_animation_chainer.animation_node_name = animation_node_name
	_animation_chainer.oneshot_node_name = oneshot_node_name
	_animation_chainer.animations = animations
	_animation_chainer.setup()
	

func physics_process(delta: float) -> void:
	_aoe_grapple.physics_process(delta)

func on_grapple_finished():
	ability_finished.emit()

func _action() -> void:
	if should_target_characters == true:
		_aoe_grapple.scan_mask = 2 + chr_layer.get_enemy_layer()
	else:
		_aoe_grapple.scan_mask = 1
	
	_aoe_grapple.scan_only_in_camera_frustum = true
	_aoe_grapple.hitbox_transform = Transform3D(character.global_basis.orthonormalized(), character.global_position) 
	#+ (character.global_basis.orthonormalized() * attack_data.local_offset))
	
	var closest_grapple_object = target_override
	
	if closest_grapple_object == null:
		closest_grapple_object = _aoe_grapple.get_closest_grapple_object()
	
	if closest_grapple_object != null:
		var chr_pos_xz_plane : Vector3 = Vector3(character.global_position.x, 0.0, character.global_position.z)
		var closest_hurtbox_pos_xz_plane : Vector3 = Vector3(closest_grapple_object.global_position.x, 0.0, closest_grapple_object.global_position.z)
		
		character.global_basis = Basis.looking_at((closest_hurtbox_pos_xz_plane - chr_pos_xz_plane).normalized(), Vector3.UP)
	#print(closest_grapple_object)
	if closest_grapple_object == null:
		on_grapple_finished()
	else:
		_animation_chainer.resume_chain()

	
func _ability_event() -> void:
	_aoe_grapple.hitbox_transform = Transform3D(character.global_basis.orthonormalized(), character.global_position) 
	
	if target_override != null and should_target_characters == true:
		_aoe_grapple.perform_grapple(target_override)
	else:
		_aoe_grapple.attempt_grapple_to_closest_object()
