class_name AnimationAttack extends AbilityComponent

enum TargetMode {
	DIRECT,
	CLOSEST_INTERACTABLE
}

var targeting_range : float = 10.0
var animations : Array[String]
var dmg : int = 10
var atk_type : AtkInfo.AtkType = AtkInfo.AtkType.MELEE
var attack_data : AttackData
var animation_node_name : String
var oneshot_node_name : String
var face_target : bool = true

var _intended_target : Node3D
var _animation_chainer : AnimationChainer
var _hurtbox_scanner : HurtBoxScanner

var _target_scan_shape : SphereShape3D
var _current_atk_dir : Vector3

func setup() -> void:
	_hurtbox_scanner = HurtBoxScanner.new()
	_hurtbox_scanner.scan_only_in_camera_frustum = true
	
	_target_scan_shape = SphereShape3D.new()
	_target_scan_shape.radius = targeting_range
	
	_animation_chainer = AnimationChainer.new()
	_animation_chainer.anim_tree = anim_tree
	_animation_chainer.animation_node_name = animation_node_name
	_animation_chainer.oneshot_node_name = oneshot_node_name
	_animation_chainer.animations = animations
	_animation_chainer.animation_finished.connect(on_animation_finish)
	_animation_chainer.setup()
	
	#print(_animation_chainer.animations)

func on_animation_finish():
	if _interrupted == false:
		ability_finished.emit()
	_animation_chainer.reset_chain()

func action() -> void:
	_interrupted = false
	_intended_target = target_override

	var attack_target = _intended_target

	#print(closest_target)
	if _intended_target == null:
		_intended_target = _hurtbox_scanner.get_closest_hurtbox_to_position(character.global_position, character.get_world_3d().direct_space_state, _target_scan_shape, character.global_transform, chr_layer.get_enemy_layer())
	
	if _intended_target != null:
		var intended_target_pos : Vector3 = _intended_target.global_position
		
		#if _intended_target is HurtBox:
			#intended_target_pos += _intended_target.hurtbox_center_offset
		#elif _intended_target is CombatCharacter:
			#intended_target_pos += _intended_target.hurt_box.hurtbox_center_offset
		
		var chr_pos_xz_plane : Vector3 = Vector3(character.global_position.x, 0.0, character.global_position.z)
		var closest_hurtbox_pos_xz_plane : Vector3 = Vector3(intended_target_pos.x, 0.0, intended_target_pos.z)
		
		_current_atk_dir = (intended_target_pos - character.global_position).normalized()
		
		if face_target == true:
			character.global_basis = Basis.looking_at((closest_hurtbox_pos_xz_plane - chr_pos_xz_plane).normalized(), Vector3.UP)
	else:
		_current_atk_dir = -character.global_basis.z
	
	_animation_chainer.resume_chain()

func cancel() -> void:
	super()
	_animation_chainer.interrupt_chain()

func ability_event() -> void:
	if is_instance_valid(_intended_target) == false:
		_intended_target = null
	
	var attack = attack_data.create_attack()
	attack.hurtboxes_hit.connect(ability_hit.emit, CONNECT_ONE_SHOT)
	attack.attack(character, 2 + 16 + chr_layer.get_enemy_layer(), dmg, atk_type, _current_atk_dir, _intended_target)
	
