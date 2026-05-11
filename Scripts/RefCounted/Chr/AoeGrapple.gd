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
var _timer : SceneTreeTimer
var _instigator_prev_pos : Vector3

signal grapple_finished

var class_grapple_callbacks : Dictionary[String, Callable] = {
	"Throwable" : throwable_grapple,
	"CombatCharacter" : character_grapple_to_target
}

func setup() -> void:
	grapple_finished.connect(on_grapple_finished)

func on_grapple_finished():
	_current_target = null
	if _grapple_line != null and is_instance_valid(_grapple_line):
		_grapple_line.queue_free()

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
		var collider_script = collider.get_script()
		
		if collider_script == null:
			continue
		
		var can_be_grappled : bool = class_grapple_callbacks.has(collider.get_script().get_global_name())
		if can_be_grappled and collider != instigator and ((scan_only_in_camera_frustum == true and instigator.get_viewport().get_camera_3d().is_position_in_frustum(collider.global_position)) or scan_only_in_camera_frustum == false):
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
	
	if _timer != null and is_instance_valid(_timer):
		if _timer.timeout.is_connected(on_timer_finish):
			_timer.timeout.disconnect(on_timer_finish)
		
		_timer = null
	
	if _grapple_line != null and is_instance_valid(_grapple_line):
		_grapple_line.queue_free()
	
	_grapple_line = GrappleLine.new()
	_grapple_line.start_node = instigator
	_grapple_line.top_level = true
	_grapple_line.use_global_space = true
	target_node.add_child(_grapple_line)
	_grapple_line.global_position = Vector3.ZERO

	
	_grapple_line.set_end_node_animated(target_node)
	_grapple_line.grapple_anim_finished.connect(func():
		class_callback.call(target_node)
	, CONNECT_ONE_SHOT)

func throwable_grapple(target_node : Throwable):
	target_node.throw_to_position(instigator.global_position + (-instigator.global_basis.z * 2))
	grapple_finished.emit()

func character_grapple_to_target(target_node : Node3D):
	#instigator.set_state("custom_movement")
	if is_instance_valid(target_node) == false:
		grapple_finished.emit()
		return
	
	_current_target = target_node
	
	if _current_target is CombatCharacter and _current_target.is_on_floor() == false:
		var target_pos = _current_target.global_position + (instigator.global_basis.z * 0.5)
		var atk_info = AtkInfo.new(0, AtkInfo.AtkType.ABILITY, instigator, instigator.global_position.direction_to(target_pos))
		_current_target.stagger(atk_info)
	
	instigator.velocity = instigator.global_position.direction_to(target_node.global_position) * grapple_reel_in_speed * instigator.get_physics_process_delta_time()
	
	_timer = instigator.get_tree().create_timer(2.0)
	_timer.timeout.connect(on_timer_finish, CONNECT_ONE_SHOT)

func on_timer_finish():
	_timer = null
	#instigator.up_velocity = Vector3.ZERO
	grapple_finished.emit()

func physics_process(delta : float):
	if _current_target != null:
		if is_instance_valid(_current_target) == false:
			_current_target = null
			grapple_finished.emit()
			print("Interrupted grapple because target has been freed")
			return
		
		var target_pos = _current_target.global_position + (instigator.global_basis.z * 0.5)
		var instigator_real_velocity : Vector3 = instigator.global_position - _instigator_prev_pos
		print(instigator_real_velocity)
		instigator.velocity = instigator.global_position.direction_to(target_pos) * grapple_reel_in_speed * delta
		_instigator_prev_pos = instigator.global_position
		if instigator.global_position.distance_to(target_pos) < grapple_finish_radius or instigator_real_velocity.length() < 0.1:
			instigator.velocity = Vector3(0.0,5.0,0.0)
			#instigator.up_velocity = Vector3.ZERO
			instigator.move_and_slide()
			#print("finished reeling to target")
			
			if _current_target is CombatCharacter and _current_target.is_on_floor() == false:
				var atk_info = AtkInfo.new(0, AtkInfo.AtkType.ABILITY, instigator, instigator.global_position.direction_to(target_pos))
				_current_target.stagger(atk_info)
			
			_current_target = null
			grapple_finished.emit()
