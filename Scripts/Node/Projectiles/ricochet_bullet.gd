class_name RicochetProjectile extends Projectile

@export var allowed_ricoshots : int = 3
@export var scan_range : float = 15.0
@export var owning_layer : CharacterLayer
@export var ricochet_speed : float = 80.0
#@export var ricochet_delay : float = 0.25

var is_ricoshot : bool = false
var blacklist : Array[HurtBox]
var _scan_shape : SphereShape3D
var target_characters : bool = false

func _ready() -> void:
	_scan_shape = SphereShape3D.new()
	_scan_shape.radius = scan_range
	
	hit.connect(ricochet)
	
	super()
	
	#if is_ricoshot == true:
		#set_physics_process(false)
		#get_tree().create_timer(ricochet_delay).timeout.connect(set_physics_process.bind(true))

func filter_for_character(hurtbox : HurtBox):
	return hurtbox.get_parent_node_3d() != null and hurtbox.get_parent_node_3d() is CombatCharacter

func filter_hurtbox_is_not_character(hurtbox : HurtBox):
	return hurtbox.get_parent_node_3d() != null and not hurtbox.get_parent_node_3d() is CombatCharacter


func ricochet(intersected_hurtbox : HurtBox):
	if allowed_ricoshots == 0:
		print("ricoshot empty")
		return
	
	var scan_blacklist = blacklist.duplicate()
	
	var hurtbox_scanner : HurtBoxScanner = HurtBoxScanner.new()
	hurtbox_scanner.blacklist = scan_blacklist
	#var closest_hurtbox : HurtBox = hurtbox_scanner.get_closest_hurtbox_to_position(intersected_hurtbox.global_position, get_world_3d().direct_space_state, _scan_shape, intersected_hurtbox.global_transform.orthonormalized(), 2 + owning_layer.get_enemy_layer())

	var nearby_hurtboxes : Array[HurtBox] = hurtbox_scanner.get_nearby_hurtboxes_from_position(get_world_3d().direct_space_state, _scan_shape, intersected_hurtbox.global_transform.orthonormalized(), 16 + owning_layer.get_enemy_layer())
	
	#if closest_hurtbox == null:
		#return
		
	if nearby_hurtboxes.size() == 0:
		print("No nearby hurtboxes")
		return
	
	var chr_hurtboxes : Array[HurtBox]
	
	if target_characters == true:
		chr_hurtboxes = nearby_hurtboxes.filter(filter_for_character)
		nearby_hurtboxes = chr_hurtboxes
	elif target_characters == false or chr_hurtboxes.size() == 0:
		nearby_hurtboxes = nearby_hurtboxes.filter(filter_hurtbox_is_not_character)
	
	if nearby_hurtboxes.size() == 0:
		return
	
	var random_hurtbox = nearby_hurtboxes.pick_random()
	var direction = intersected_hurtbox.global_position.direction_to(random_hurtbox.global_position + random_hurtbox.hurtbox_center_offset)
	
	var new_bullet : RicochetProjectile = load(scene_file_path).instantiate()
	new_bullet.allowed_ricoshots = allowed_ricoshots - 1
	
	if not intersected_hurtbox.get_parent_node_3d() is CombatCharacter:
		blacklist.append(intersected_hurtbox)
	new_bullet.blacklist = blacklist
	new_bullet.atk_info = atk_info
	new_bullet.max_lifetime = max_lifetime
	new_bullet.speed = ricochet_speed
	new_bullet.target_characters = not target_characters
	
	get_tree().current_scene.add_child(new_bullet)
	new_bullet.global_basis = Basis.looking_at(direction)
	new_bullet.global_position = intersected_hurtbox.global_position + (direction * 2.0)
