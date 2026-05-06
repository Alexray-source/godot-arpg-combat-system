extends SceneAttackInstance

@export var main_object : Node3D
@export var decal : Decal
@export var attack_vfx : Array[GPUParticles3D]
@export var chr_layer_owner : CharacterLayer
@export var hitbox : BoxShape3D
@export var travel_time : float = 1.0

var target_scan_range : float = 50.0

var _target : Node3D
var _direct_space_state  : PhysicsDirectSpaceState3D
var _physics_shape_query_params : PhysicsShapeQueryParameters3D
var _start_pos : Vector3

func _ready() -> void:
	_physics_shape_query_params = PhysicsShapeQueryParameters3D.new()
	_physics_shape_query_params.collide_with_areas = true
	_physics_shape_query_params.collide_with_bodies = true
	_physics_shape_query_params.collision_mask = 13
	_physics_shape_query_params.shape = hitbox
	
	_direct_space_state = main_object.get_world_3d().direct_space_state
	
	var scan_shape : SphereShape3D = SphereShape3D.new()
	scan_shape.radius = target_scan_range
	
	var combat_chr_scanner = CombatCharacterScanner.new()
	combat_chr_scanner.scan_only_in_camera_frustum = false
	
	_target = combat_chr_scanner.get_closest_character_to_position(main_object.global_position, _direct_space_state, scan_shape, main_object.global_transform, chr_layer_owner.get_enemy_layer())
	
	var move_tween = create_tween()
	move_tween.set_ease(Tween.EASE_IN)
	move_tween.set_trans(Tween.TRANS_QUAD)
	move_tween.tween_method(move_to_target, 0.0, 1.0, travel_time)
	move_tween.finished.connect(spawn_sword_pillar, CONNECT_ONE_SHOT)

func move_to_target(factor : float):
	main_object.global_position = spawn_transform.origin.lerp(_target.global_position, factor)

func spawn_sword_pillar():
	await get_tree().create_timer(0.25).timeout
	decal.visible = false
	
	var aoe_hitbox : AoeHitbox = AoeHitbox.new()
	aoe_hitbox.atk_dir_from_aoe_center = true
	aoe_hitbox.atk_info = atk_info
	aoe_hitbox.direct_space_state = _direct_space_state
	aoe_hitbox.hitbox_transform = main_object.global_transform
	aoe_hitbox.scan_mask = chr_layer_owner.get_enemy_layer()
	aoe_hitbox.hit_shape = hitbox
	aoe_hitbox.attack()
	
	for particle in attack_vfx:
		particle.emitting = true
	
	await get_tree().create_timer(1.0).timeout
	queue_free()
