class_name AnimationAttack extends AbilityComponent

var targeting_range : float = 10.0
var animations : Array[String]
var dmg : int = 10
var atk_type : AtkInfo.AtkType = AtkInfo.AtkType.MELEE
var attack_data : AttackData
var animation_node_name : String
var oneshot_node_name : String

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
	ability_finished.emit()
	_animation_chainer.reset_chain()

func action() -> void:
	var closest_target = target_override
	#print(closest_target)
	if closest_target == null:
		closest_target = _hurtbox_scanner.get_closest_hurtbox_to_position(character.global_position, character.get_world_3d().direct_space_state, _target_scan_shape, character.global_transform, chr_layer.get_enemy_layer())
	
	if closest_target != null:
		var chr_pos_xz_plane : Vector3 = Vector3(character.global_position.x, 0.0, character.global_position.z)
		var closest_hurtbox_pos_xz_plane : Vector3 = Vector3(closest_target.global_position.x, 0.0, closest_target.global_position.z)
		
		_current_atk_dir = (closest_target.global_position - character.global_position).normalized()
		
		character.global_basis = Basis.looking_at((closest_hurtbox_pos_xz_plane - chr_pos_xz_plane).normalized(), Vector3.UP)
	else:
		_current_atk_dir = -character.global_basis.z
	
	_animation_chainer.resume_chain()

func ability_event() -> void:
	var attack = attack_data.create_attack()
	attack.hurtboxes_hit.connect(ability_hit.emit, CONNECT_ONE_SHOT)
	attack.attack(character, 2 + chr_layer.get_enemy_layer(), dmg, atk_type, _current_atk_dir)
