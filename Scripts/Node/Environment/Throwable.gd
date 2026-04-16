class_name Throwable extends RigidBody3D

@export var hurtbox : HurtBox
@export var accepted_atk_types : Array[AtkInfo.AtkType]
@export var damage : float = 20.0
@export var allowed_target_hits : int = 1

var total_target_hits : int = 0

##Other hurtboxes call this signal
signal target_hit()

func _ready() -> void:
	hurtbox.hit.connect(on_hit)
	target_hit.connect(on_target_hit)

func throw(direction : Vector3, power : float) -> void:
	linear_velocity = Vector3.ZERO
	apply_central_impulse(direction * power)
	apply_torque_impulse(direction.rotated(Vector3.UP, PI*0.5) * randf_range(2.0, 6.0))

func throw_to_position(target_position : Vector3, speed : float = 0.1) -> void:
	var g = get_gravity()
	var x0 = global_position
	var end_pos = target_position
		
	var t = global_position.distance_to(target_position) * speed
	var v0 = (end_pos - x0 - 0.5*g*t*t)/t
	throw(v0.normalized(), v0.length())

func on_hit(atk_info : AtkInfo) -> void:
	if atk_info.atk_type == AtkInfo.AtkType.MASSIVE_PROJECTILE:
		return
		
	var scan_layer = 2
	var intended_target : Node3D = atk_info.intended_target
	
	if atk_info.instigator is CombatCharacter:
		scan_layer = atk_info.instigator.chr_layer.get_enemy_layer()
	
	if accepted_atk_types.find(atk_info.atk_type) != -1:
		var throw_dir = atk_info.atk_dir
		var scan_shape : BoxShape3D = BoxShape3D.new()
		scan_shape.size = Vector3(15.0, 15.0, 100.0)
		
		var scan_transform = Transform3D(Basis.looking_at(atk_info.atk_dir), atk_info.instigator.global_position + (atk_info.atk_dir * scan_shape.size.z * 0.5))
		
		var hurtbox_scanner = HurtBoxScanner.new()
		hurtbox_scanner.blacklist.append(hurtbox)
		
		if intended_target == null:
			intended_target = hurtbox_scanner.get_closest_hurtbox_to_position(atk_info.instigator.global_position, get_world_3d().direct_space_state, scan_shape, scan_transform, scan_layer)
		
		if intended_target != null:
			throw_dir = global_position.direction_to(intended_target.global_position)
			throw_to_position(intended_target.global_position, 0.025)
		else:
			throw((throw_dir + Vector3(0,0.1,0.0)).normalized(), atk_info.dmg * mass * 2.0)

		
func on_target_hit() -> void:
	total_target_hits += 1
	
	if allowed_target_hits > 0 and total_target_hits >= allowed_target_hits:
		queue_free()
