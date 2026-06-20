class_name Projectile extends Node3D

@export var speed : float = 100.0
@export var max_lifetime : float = 5.0
@export var hit_vfx : String = "projectile_hit"
@export var hit_event : ProjectileHit
@export var re_evaluate_atk_dir_on_ready : bool = false
@export var target_movement_prediction : bool = true

var spawn_transform : Transform3D
var direct_space_state : PhysicsDirectSpaceState3D
var ray_params : PhysicsRayQueryParameters3D
var atk_info : AtkInfo
var lifetime : float = 0.0

signal hit(intersected_collider : HurtBox)

func _ready() -> void:
	direct_space_state = get_world_3d().direct_space_state
	
	ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.collide_with_areas = true
	ray_params.collide_with_bodies = true
	ray_params.collision_mask = 15 + 16
	
	var atk_dir = atk_info.atk_dir
	
	if re_evaluate_atk_dir_on_ready == true and atk_info.intended_target != null:
		atk_dir = spawn_transform.origin.direction_to(atk_info.intended_target.global_position)
	
	if target_movement_prediction == true and atk_info.intended_target is CharacterBody3D:
		var projectile_travel_time = spawn_transform.origin.distance_to(atk_info.intended_target.global_position) / speed
		var target_predicted_travel = atk_info.intended_target.velocity * projectile_travel_time
		var target_predicted_position = atk_info.intended_target.global_position + target_predicted_travel
		
		atk_dir = spawn_transform.origin.direction_to(target_predicted_position)
	
	global_position = spawn_transform.origin + (-atk_info.instigator.global_basis.z * 0.6)
	global_basis = Basis.looking_at(atk_dir)


func _physics_process(delta: float) -> void:
	lifetime += delta
	if lifetime > max_lifetime:
		queue_free()
	
	var next_pos : Vector3 = global_position + (-global_basis.z * speed * delta)
	
	ray_params.from = global_position
	ray_params.to = next_pos
	
	global_position = next_pos
	var result = direct_space_state.intersect_ray(ray_params)
	
	var intersected_collider = result.get("collider")
	
	if intersected_collider != null:
		if intersected_collider is HurtBox:
			#intersected_collider.hit.emit(atk_info)
			hit_event.on_hit(intersected_collider, atk_info)
			hit.emit(intersected_collider)
		GlobalSignals.spawn_vfx.emit(hit_vfx, Transform3D(Basis.IDENTITY, result.get("position")))
		queue_free()
