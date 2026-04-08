class_name Projectile extends Node3D

@export var speed : float = 100.0
@export var max_lifetime : float = 5.0

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
	ray_params.collision_mask = 13

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
			#print("hurtbox")
			intersected_collider.hit.emit(atk_info)
			hit.emit(intersected_collider)
		else:
			queue_free()
