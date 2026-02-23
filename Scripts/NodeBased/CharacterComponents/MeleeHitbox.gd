extends CharacterComponent
class_name MeleeHitbox

@export var hit_shape : SphereShape3D
@export var node_origin : Node3D
@export var local_offset : Vector3
@export var scan_mask : int = 1

var atk_info : AtkInfo

func action() -> void:
	var shape_cast_params = PhysicsShapeQueryParameters3D.new()
	shape_cast_params.shape = hit_shape
	shape_cast_params.transform = Transform3D(node_origin.global_basis.orthonormalized(), node_origin.global_position + (node_origin.global_basis.orthonormalized() * local_offset))
	shape_cast_params.collision_mask = scan_mask
	shape_cast_params.collide_with_areas = true
	shape_cast_params.collide_with_bodies = false
	
	#var sphere = SphereMesh.new()
	#sphere.height = hit_shape.radius * 2.0
	#sphere.radius = hit_shape.radius
	#
	#var mesh_inst = MeshInstance3D.new()
	#mesh_inst.mesh = sphere
	#mesh_inst.top_level = true
	#add_child(mesh_inst)
	#mesh_inst.global_position = shape_cast_params.transform.origin
	
	var results = node_origin.get_world_3d().direct_space_state.intersect_shape(shape_cast_params)
	for hit in results:
		var collider = hit.get("collider")
		if collider is HurtBox:
			collider.hit.emit(atk_info)
