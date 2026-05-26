class_name RicochetProjectile extends Projectile

@export var allowed_ricoshots : int = 3
@export var scan_range : float = 15.0
@export var owning_layer : CharacterLayer
@export var ricochet_speed : float = 80.0
#@export var ricochet_delay : float = 0.25

var is_ricoshot : bool = false
var blacklist : Array[HurtBox]
var _scan_shape : SphereShape3D

func _ready() -> void:
	_scan_shape = SphereShape3D.new()
	_scan_shape.radius = scan_range
	
	hit.connect(ricochet)
	
	super()
	
	#if is_ricoshot == true:
		#set_physics_process(false)
		#get_tree().create_timer(ricochet_delay).timeout.connect(set_physics_process.bind(true))



func ricochet(intersected_hurtbox : HurtBox):
	if allowed_ricoshots == 0:
		return
	
	var scan_blacklist = blacklist.duplicate()
	scan_blacklist.append(intersected_hurtbox)
	
	var hurtbox_scanner : HurtBoxScanner = HurtBoxScanner.new()
	hurtbox_scanner.blacklist = scan_blacklist
	var closest_hurtbox : HurtBox = hurtbox_scanner.get_closest_hurtbox_to_position(intersected_hurtbox.global_position, get_world_3d().direct_space_state, _scan_shape, intersected_hurtbox.global_transform.orthonormalized(), 2 + owning_layer.get_enemy_layer())
	
	if closest_hurtbox == null:
		return
	
	#if nearby_hurtboxes.size() == 0:
		#return
	#
	#var random_hurtbox = nearby_hurtboxes.pick_random()
	var direction = intersected_hurtbox.global_position.direction_to(closest_hurtbox.global_position)
	
	var new_bullet : RicochetProjectile = load(scene_file_path).instantiate()
	new_bullet.allowed_ricoshots = allowed_ricoshots - 1
	
	if not intersected_hurtbox.get_parent_node_3d() is CombatCharacter:
		blacklist.append(intersected_hurtbox)
	new_bullet.blacklist = blacklist
	new_bullet.atk_info = atk_info
	new_bullet.max_lifetime = max_lifetime
	new_bullet.speed = ricochet_speed
	
	get_tree().current_scene.add_child(new_bullet)
	new_bullet.global_basis = Basis.looking_at(direction)
	new_bullet.global_position = intersected_hurtbox.global_position + (-new_bullet.global_basis.z * 2.0)
