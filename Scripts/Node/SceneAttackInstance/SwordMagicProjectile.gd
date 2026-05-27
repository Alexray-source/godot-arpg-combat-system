extends SceneAttackInstance

@export var scan_origin : Node3D
@export var target_projectile : Node3D
@export var chr_layer_owner : CharacterLayer
@export var max_lifetime : float = 5.0
@export var hitbox : BoxShape3D
@export var projectile_speed : float = 3.0
@export var shoot_time : float = 1.0
@export var target_shoot_offset : Vector3
@export var targetting_speed : float = 20.0
@export var shoot_sfx : AudioStreamPlayer3D
var target_scan_range : float = 50.0

var _target : Node3D
var _is_shooting : bool = false
var _lifetime : float = 0.0
var _shoot_dir : Vector3
var _direct_space_state  : PhysicsDirectSpaceState3D
var _physics_shape_query_params : PhysicsShapeQueryParameters3D

func _ready() -> void:
	_physics_shape_query_params = PhysicsShapeQueryParameters3D.new()
	_physics_shape_query_params.collide_with_areas = true
	_physics_shape_query_params.collide_with_bodies = true
	_physics_shape_query_params.collision_mask = 12
	
	_direct_space_state = get_viewport().world_3d.direct_space_state
	
	var scan_shape : SphereShape3D = SphereShape3D.new()
	scan_shape.radius = target_scan_range
	
	var combat_chr_scanner = CombatCharacterScanner.new()
	combat_chr_scanner.scan_only_in_camera_frustum = false
	
	_target = combat_chr_scanner.get_closest_character_to_position(scan_origin.global_position, _direct_space_state, scan_shape, scan_origin.global_transform, chr_layer_owner.get_enemy_layer())
	
	if attack_indicator.is_empty() == false:
		get_tree().create_timer(shoot_time - 0.35).timeout.connect(telegraph)
	
	get_tree().create_timer(shoot_time).timeout.connect(shoot_to_target, CONNECT_ONE_SHOT)

func telegraph():
	show_indicator(target_projectile.global_transform)

func shoot_to_target() -> void:
	shoot_sfx.play()
	_is_shooting = true

func _physics_process(delta: float) -> void:
	if _is_shooting == false and _target != null:
		_shoot_dir = _shoot_dir.lerp(scan_origin.global_position.direction_to(_target.global_position + target_shoot_offset), targetting_speed * delta)
		target_projectile.global_basis = Basis.looking_at(_shoot_dir)
		return
	
	_lifetime += delta
	if _lifetime > max_lifetime:
		queue_free()
	
	
	var next_pos : Vector3 = target_projectile.global_position + (-target_projectile.global_basis.z * projectile_speed * delta)
	var gap = target_projectile.global_position.distance_to(next_pos)
	
	var gap_hitbox = hitbox.duplicate()
	gap_hitbox.size.z += gap
	
	_physics_shape_query_params.shape = gap_hitbox
	
	var halfway_next_pos = target_projectile.global_position + ((next_pos - target_projectile.global_position) * 0.5)
	
	target_projectile.global_position = next_pos
	
	_physics_shape_query_params.transform = Transform3D(target_projectile.global_basis.orthonormalized(), halfway_next_pos)
	var scan_result = _direct_space_state.intersect_shape(_physics_shape_query_params)
	
	#var box_mesh_preview : BoxMesh = BoxMesh.new()
	#box_mesh_preview.size = gap_hitbox.size
	#
	#var mesh_preview = MeshInstance3D.new()
	#
	#get_tree().current_scene.add_child(mesh_preview)
	#
	#mesh_preview.global_position = halfway_next_pos
	#mesh_preview.global_basis = target_projectile.global_basis.orthonormalized()
	#mesh_preview.mesh = box_mesh_preview
	
	var should_destroy : bool = false
	for result in scan_result:
		should_destroy = true
		var collider = result.get("collider")
		#print(collider.name)

		if collider is HurtBox:
			collider.hit.emit(atk_info)
	
	#queue_free()
	#
	if should_destroy == true:
		queue_free()
