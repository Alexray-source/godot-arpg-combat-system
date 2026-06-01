class_name ShapeCastProjectile extends Projectile

@export var target_projectile : Node3D
@export var hitbox : BoxShape3D
@export var target_shoot_offset : Vector3
@export var destroy_on_hit : bool = true

var target_scan_range : float = 50.0
var _has_hit : bool = false
var _lifetime : float = 0.0
var _direct_space_state  : PhysicsDirectSpaceState3D
var _physics_shape_query_params : PhysicsShapeQueryParameters3D
var _hurtboxes_hit : Array[HurtBox]


func _ready() -> void:
	super()
	
	_physics_shape_query_params = PhysicsShapeQueryParameters3D.new()
	_physics_shape_query_params.collide_with_areas = true
	_physics_shape_query_params.collide_with_bodies = true
	_physics_shape_query_params.collision_mask = 12
	print(_physics_shape_query_params.collision_mask)
	_direct_space_state = get_viewport().world_3d.direct_space_state

func _physics_process(delta: float) -> void:
	_lifetime += delta
	if _lifetime > max_lifetime:
		queue_free()
	
	
	var next_pos : Vector3 = target_projectile.global_position + (-target_projectile.global_basis.z * speed * delta)
	var gap = target_projectile.global_position.distance_to(next_pos)
	
	var gap_hitbox = hitbox.duplicate()
	gap_hitbox.size.z += gap
	
	_physics_shape_query_params.shape = gap_hitbox
	
	var halfway_next_pos = target_projectile.global_position + ((next_pos - target_projectile.global_position) * 0.5)
	
	target_projectile.global_position = next_pos
	
	_physics_shape_query_params.transform = Transform3D(target_projectile.global_basis.orthonormalized(), halfway_next_pos)
	var scan_result = _direct_space_state.intersect_shape(_physics_shape_query_params)
	#
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
	#
	for result in scan_result:
		_has_hit = true
		var collider = result.get("collider")

		if collider is HurtBox and _hurtboxes_hit.has(collider) == false:
			_hurtboxes_hit.append(collider)
			#collider.hit.emit(atk_info)
	
	#queue_free()
	#
	if _has_hit == true:
		for hurtbux in _hurtboxes_hit:
			hit_event.on_hit(hurtbux, atk_info)
			hit.emit(hurtbux)
		
		if destroy_on_hit == true:
			queue_free()
