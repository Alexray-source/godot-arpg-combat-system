class_name Throwable extends RigidBody3D

const OUTLINE_MAT : ShaderMaterial = preload("res://Assets/Material/kickable_outline.tres")

@export var hurtbox : HurtBox
@export var accepted_atk_types : Array[AtkInfo.AtkType]
@export var damage : float = 20.0
@export var allowed_target_hits : int = 1
@export var mesh_instance : MeshInstance3D

@export var hit_sfx_player : AudioStreamPlayer3D
@export var shoot_sfx_player : AudioStreamPlayer3D

var total_target_hits : int = 0
var _highlight_origin : Node3D
var _outline_mesh_instance : MeshInstance3D

##Other hurtboxes call this signal
signal target_hit()

func _ready() -> void:
	hurtbox.hit.connect(on_hit)
	target_hit.connect(on_target_hit)
	
	var outline_mesh : Mesh = mesh_instance.mesh
	_outline_mesh_instance = MeshInstance3D.new()
	_outline_mesh_instance.mesh = outline_mesh
	_outline_mesh_instance.material_override = OUTLINE_MAT
	
	mesh_instance.add_child(_outline_mesh_instance)
	
	_highlight_origin = get_tree().get_first_node_in_group("player_chr")
	
	GlobalSignals.plr_chr_changed.connect(set_highlight_origin)
	set_process(_highlight_origin != null)

func set_highlight_origin(new_origin : Node3D):
	_highlight_origin = new_origin
	
	set_process(_highlight_origin != null)

func _process(_delta: float) -> void:
	var dist : float = _highlight_origin.global_position.distance_to(global_position)
	
	_outline_mesh_instance.set_instance_shader_parameter("opacity", clampf(5.0 - dist, 0.0, 1.0 ))

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
		
		hit_sfx_player.play()
		
		if intended_target != null:
			throw_dir = global_position.direction_to(intended_target.global_position)
			#throw_to_position(intended_target.global_position, 0.025)
			#throw(throw_dir, 50.0 * mass)
		#else:
		throw((throw_dir + Vector3(0,0.1,0.0)).normalized(), 50.0 * mass)
	
	
func on_target_hit() -> void:
	total_target_hits += 1
	
	if allowed_target_hits > 0 and total_target_hits >= allowed_target_hits:
		queue_free()
