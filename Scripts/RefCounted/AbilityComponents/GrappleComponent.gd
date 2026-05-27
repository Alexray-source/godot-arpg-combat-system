class_name GrappleComponent extends AbilityComponent

const GRAPPLE_RETICLE_SCENE : PackedScene = preload("res://Scenes/UI/grapple_reticle.tscn")

var targeting_range : float = 20.0
var animation_node_name : String
var oneshot_node_name : String
var animations : Array[String]
var show_closest_indicator : bool = false

var _animation_chainer : AnimationChainer
var _aoe_grapple : AoeGrapple
var _closest_node_tracker : ClosestFacingNode3DTracker
var _scan_shape : ConvexPolygonShape3D = load("res://Assets/CollisionShapes/view_cone.tres")

var _indicator_area : Area3D
var _3d_closest_indicator : Node3D
var _closest_node : Node3D

func setup() -> void:
	#_scan_shape = SphereShape3D.new()
	#_scan_shape.radius = targeting_range
	#
	_aoe_grapple = AoeGrapple.new()
	_aoe_grapple.instigator = character
	_aoe_grapple.hit_shape = _scan_shape
	_aoe_grapple.grapple_finish_radius = 2.0
	_aoe_grapple.direct_space_state = character.get_world_3d().direct_space_state
	_aoe_grapple.grapple_finished.connect(on_grapple_finished)
	_aoe_grapple.setup()
	
	_animation_chainer = AnimationChainer.new()
	_animation_chainer.anim_tree = anim_tree
	_animation_chainer.animation_node_name = animation_node_name
	_animation_chainer.oneshot_node_name = oneshot_node_name
	_animation_chainer.animations = animations
	_animation_chainer.setup()
	
	if show_closest_indicator == true:
		_3d_closest_indicator = GRAPPLE_RETICLE_SCENE.instantiate()
		_3d_closest_indicator.top_level = true
		
		character.add_child(_3d_closest_indicator)
		_3d_closest_indicator.visible = false
		
		_closest_node_tracker = ClosestFacingNode3DTracker.new()
		_closest_node_tracker.only_in_camera = true
		_closest_node_tracker.ignore_y = true
		_closest_node_tracker.camera = character.get_viewport().get_camera_3d()
		_closest_node_tracker.closest_node_changed.connect(on_closest_node_changed)
		
		_indicator_area = Area3D.new()
		_indicator_area.body_entered.connect(add_node_to_nearby_list)
		_indicator_area.body_exited.connect(erase_node_from_nearby_list)
		_indicator_area.area_entered.connect(add_node_to_nearby_list)
		_indicator_area.area_exited.connect(erase_node_from_nearby_list)
		
		_indicator_area.collision_mask = 2 + 16 + chr_layer.get_enemy_layer()
			
		var collision_shape : CollisionShape3D = CollisionShape3D.new()
		collision_shape.shape = _scan_shape
		
		_indicator_area.add_child(collision_shape)
		character.add_child(_indicator_area)

func add_node_to_nearby_list(new_node : Node3D):
	if new_node == character or _aoe_grapple.get_grapple_mode_from_node(new_node) == AoeGrapple.GrappleMode.INVALID:
		return
	
	_closest_node_tracker.node_list.append(new_node)

func erase_node_from_nearby_list(removing_node : Node3D):
	_closest_node_tracker.node_list.erase(removing_node)

func physics_process(delta: float) -> void:
	if show_closest_indicator == true:
		_closest_node_tracker.scan_transform = character.global_transform.orthonormalized()
		_closest_node_tracker.poll(delta)
		
		if _3d_closest_indicator.visible and _closest_node != null:
			_3d_closest_indicator.global_position = _closest_node.global_position
			
			if target_override != null:
				var direction_to_priority_target = character.global_position.direction_to(target_override.global_position)
				var priority_dot_direction_result = -character.global_basis.z.dot(direction_to_priority_target)
				
				if priority_dot_direction_result > 0.8:
					_3d_closest_indicator.global_position = target_override.global_position
	
	_aoe_grapple.physics_process(delta)

func on_closest_node_changed(new_node : Node3D):
	_closest_node = new_node
	#print("New closest grapple node: " + str(new_node))
	_3d_closest_indicator.visible = new_node != null

func on_grapple_finished():
	if _interrupted == true:
		return
	
	ability_finished.emit()

func action() -> void:
	_interrupted = false
	
	_aoe_grapple.scan_mask = 2 + 16 + chr_layer.get_enemy_layer()
	_aoe_grapple.scan_only_in_camera_frustum = true
	_aoe_grapple.hitbox_transform = Transform3D(character.global_basis.orthonormalized(), character.global_position) 
	
	var closest_grapple_object = _aoe_grapple.get_closest_grapple_object()
	
	if closest_grapple_object != null:
		var chr_pos_xz_plane : Vector3 = Vector3(character.global_position.x, 0.0, character.global_position.z)
		var closest_hurtbox_pos_xz_plane : Vector3 = Vector3(closest_grapple_object.global_position.x, 0.0, closest_grapple_object.global_position.z)
		
		character.global_basis = Basis.looking_at((closest_hurtbox_pos_xz_plane - chr_pos_xz_plane).normalized(), Vector3.UP)
	
	#print(closest_grapple_object)
	if closest_grapple_object == null:
		on_grapple_finished()
	else:
		_animation_chainer.resume_chain()

func cancel() -> void:
	super()
	_aoe_grapple.on_grapple_finished()

func ability_event() -> void:
	_aoe_grapple.hitbox_transform = Transform3D(character.global_basis.orthonormalized(), character.global_position) 
	print("Grapple Event")
	_aoe_grapple.attempt_grapple_to_closest_object(target_override)
	#if target_override != null and grapple_mode == AoeGrapple.GrappleMode.REEL:
		#_aoe_grapple.perform_grapple(target_override)
	#else:
		#_aoe_grapple.attempt_grapple_to_closest_object()
