class_name ThrowExplosion extends SceneAttackInstance

@export var radius : float = 5.0
@export var throw_speed : float = 60.0
@export var float_duration : float = 2.0
@export var vfx_key : String

var _floating_throwables : Dictionary[Throwable, Vector3]

func _ready() -> void:
	super()
	GlobalSignals.spawn_vfx.emit(vfx_key, Transform3D(spawn_transform.basis * radius * 2, spawn_transform.origin) )
	
	var sphere_shape : SphereShape3D = SphereShape3D.new()
	sphere_shape.radius = radius
	
	var hurtbox_scanner : HurtBoxScanner = HurtBoxScanner.new()
	var nearby_hurtboxes : Array[HurtBox] = hurtbox_scanner.get_nearby_hurtboxes_from_position(get_world_3d().direct_space_state, sphere_shape, spawn_transform, 16)
	
	var target = atk_info.intended_target
	
	for hurtbox in nearby_hurtboxes:
		var parent = hurtbox.get_parent_node_3d()
		if parent != null and parent is Throwable and target != null:
			_floating_throwables.set(parent, parent.global_position + Vector3(0.0, randf_range(2.0, 5.0), 0.0))
			get_tree().create_timer(float_duration + randf_range(0.0,0.3)).timeout.connect(throw.bind(parent))

func throw(throwable : Throwable):
	show_indicator(throwable.global_transform)
	
	await get_tree().create_timer(0.5).timeout
	
	var target = atk_info.intended_target
	var direction = throwable.global_position.direction_to(target.global_position)
	
	_floating_throwables.erase(throwable)
	throwable.throw(direction, throw_speed)

func _physics_process(delta: float) -> void:
	for throwable in _floating_throwables:
		var target_pos : Vector3 = _floating_throwables[throwable]
		throwable.apply_force((target_pos - throwable.global_position ) * delta * throwable.mass * 700.0)
		throwable.apply_torque(Vector3.RIGHT * delta * 100.0)
		
		
		
