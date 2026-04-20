class_name AoeGrapple extends RefCounted

var scan_only_in_camera_frustum : bool = false
var hitbox_transform : Transform3D
var hit_shape : Shape3D
var scan_mask : int = 1
var direct_space_state : PhysicsDirectSpaceState3D
var instigator : BaseCharacter
var grapple_finish_radius : float = 1.0
var grapple_reel_in_speed : float = 3000.0

var _current_target : Node3D
var _grapple_line : GrappleLine

signal grapple_finished

var class_grapple_callbacks : Dictionary[String, Callable] = {
	"Throwable" : throwable_grapple,
	"CombatCharacter" : character_grapple_to_target
}

func setup() -> void:
	grapple_finished.connect(func():
		_current_target = null
	)

func get_closest_grapple_object() -> Throwable:
	var shape_cast_params = PhysicsShapeQueryParameters3D.new()
	shape_cast_params.shape = hit_shape
	shape_cast_params.transform = hitbox_transform
	shape_cast_params.collision_mask = scan_mask
	shape_cast_params.collide_with_areas = false
	shape_cast_params.collide_with_bodies = true

	var closest_body : PhysicsBody3D
	var closest_dist : float = 10000.0
	
	var results = direct_space_state.intersect_shape(shape_cast_params)
	for hit in results:
		var collider = hit.get("collider")
		if collider is PhysicsBody3D and collider != instigator and ((scan_only_in_camera_frustum == true and instigator.get_viewport().get_camera_3d().is_position_in_frustum(collider.global_position)) or scan_only_in_camera_frustum == false):
			var body_dist = collider.global_position.distance_to(instigator.global_position)
			if body_dist < closest_dist:
				closest_dist = body_dist
				closest_body = collider
	
	return closest_body

func attempt_grapple_to_closest_object():
	var closest_body : PhysicsBody3D = get_closest_grapple_object()
	
	if closest_body == null:
		return
	
	var attached_script = closest_body.get_script()
	if attached_script != null:
		perform_grapple(closest_body)
	else:
		grapple_finished.emit()

func perform_grapple(target_node : Node3D):
	var class_callback : Callable = class_grapple_callbacks.get(target_node.get_script().get_global_name())
	
	if class_callback == null:
		grapple_finished.emit()
		return
	
	_grapple_line = GrappleLine.new()
	_grapple_line.start_node = instigator
	_grapple_line.top_level = true
	_grapple_line.use_global_space = true
	target_node.add_child(_grapple_line)
	_grapple_line.global_position = Vector3.ZERO

	
	_grapple_line.set_end_node_animated(target_node)
	_grapple_line.grapple_anim_finished.connect(func():
		class_callback.call(target_node)
		_grapple_line.set_end_node_animated(instigator)
		
		#_grapple_line.grapple_anim_finished.connect(func():
			#_grapple_line.queue_free()
			#_grapple_line = null
		#, CONNECT_ONE_SHOT)
	, CONNECT_ONE_SHOT)

func throwable_grapple(target_node : Throwable):
	target_node.throw_to_position(instigator.global_position + (-instigator.global_basis.z * 2))
	grapple_finished.emit()

func character_grapple_to_target(target_node : Node3D):
	#if target_node is CombatCharacter:
		##target_node.set_state("custom_movement")
		##target_node.velocity = Vector3.ZERO
		#target_node.stagger()
	
	instigator.set_state("custom_movement")
	_current_target = target_node
	instigator.velocity = instigator.global_position.direction_to(target_node.global_position) * grapple_reel_in_speed * instigator.get_physics_process_delta_time()
	instigator.get_tree().create_timer(0.5).timeout.connect(func():
		instigator.up_velocity = Vector3.ZERO
		grapple_finished.emit()
		, CONNECT_ONE_SHOT)

func physics_process(delta : float):
	if _current_target != null:
		var target_pos = _current_target.global_position + (instigator.global_basis.z * 0.5)
		
		instigator.velocity = instigator.global_position.direction_to(target_pos) * grapple_reel_in_speed * delta
		if instigator.global_position.distance_to(target_pos) < grapple_finish_radius:
			instigator.velocity = Vector3.ZERO
			instigator.up_velocity = Vector3.ZERO
			instigator.move_and_slide()
			#print("finished reeling to target")
			
			if _current_target is CombatCharacter:
				#target_node.set_state("custom_movement")
				#target_node.velocity = Vector3.ZERO
				_current_target.prev_hit_info = AtkInfo.new(0, AtkInfo.AtkType.ABILITY, instigator, instigator.global_position.direction_to(target_pos))
				_current_target.stagger()
			
			_current_target = null
			grapple_finished.emit()
