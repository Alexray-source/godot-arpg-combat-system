@tool
extends MeshInstance3D
class_name TerrainMeshInstance

enum VertexChannel {
	R,
	G,
	B,
	ALL
}

@export var enable_foilage : bool = false
@export var scattered_mesh : Mesh
#@export var mesh_instance : MeshInstance3D
@export var grass_count : int = 100
@export var grass_vertex_channel : VertexChannel = VertexChannel.G
@export var uniform_scale : float = 1.5
@export var uniform_scale_random : float = 0.3

@export_range(0.0,1.0) var grass_threshold : float = 0.3
@export_range(0.0,1.0) var slope_threshold : float = 0.9

@export_tool_button("Generate Grass") var generate_action = generate_grass
@export_tool_button("Generate Empty Splatmap") var generate_splat_action = generate_empty_splat

@export var use_vertex_colors : bool = false
@export var splatmap : Texture2D
@export_tool_button("Update Material") var update_material_action = update_shader_mat

@export var uv_correction_scale : float = 1.0
@export_tool_button("Update UVs") var uv_update_action = update_texture_uvs

@export_subgroup("Material Settings")
@export var base_material : ShaderMaterial

@export_subgroup("LOD Meshes")
#Dictionary[Lod start distance, lod mesh]
@export var lod_levels : Dictionary[float, Mesh]

#@export var normalmap : Texture2D:
	#set(value):
		#normalmap = value
		

#var multi_mesh : MultiMesh
#var multi_mesh_instance : MultiMeshInstance3D
var mdt : MeshDataTool

var lod_detail : float = 0.15

var transform_vertex_to_global : bool
var grass_blade_rids : Array[RID]
var lods : Array[RID]

signal new_splat_generated()

func _ready() -> void:
	cleanup()
	lod_bias = lod_detail
	update_texture_uvs()
	mdt = MeshDataTool.new()
	setup_lods()
	if Engine.is_editor_hint() == false:
		generate_grass()
	else:
		update_shader_mat()

#
func _enter_tree() -> void:
	cleanup()
	setup_lods()

func setup_lods():
	if lod_levels.size() > 0:
		var prev_instance = get_instance()
		for lod_start_dist in lod_levels:
			var lod_mesh : Mesh = lod_levels[lod_start_dist]
			var lod_instance = RenderingServer.instance_create()
			RenderingServer.instance_set_base(lod_instance, lod_mesh)
			RenderingServer.instance_set_transform(lod_instance, global_transform)
			RenderingServer.instance_geometry_set_visibility_range(lod_instance, lod_start_dist, 0.0, 0.0, 0.0, RenderingServer.VISIBILITY_RANGE_FADE_DISABLED)
			RenderingServer.instance_set_visibility_parent(prev_instance, lod_instance)
			
			lods.append(lod_instance)
			RenderingServer.instance_set_scenario(lod_instance, get_world_3d().scenario)
			
			prev_instance = lod_instance

func _exit_tree() -> void:
	cleanup()

func remove_all_grass():
	if grass_blade_rids.size() > 0:
		for grass_blade_rid in grass_blade_rids:
			RenderingServer.free_rid(grass_blade_rid)

func cleanup():
	if lods.size() > 0:
		for lod in lods:
			RenderingServer.free_rid(lod)
	
	remove_all_grass()

func generate_empty_splat():
	var tex = GradientTexture2D.new()
	
	var dark_gradient = Gradient.new()
	for point_count in range(dark_gradient.get_point_count()):
		dark_gradient.set_color(point_count, Color.BLACK)
	tex.gradient = dark_gradient
	
	splatmap = tex
	new_splat_generated.emit()

func create_grass_blades(grass_blade_id : int, target_transform : Transform3D, normal_vector : Vector3 = Vector3(0.0,1.0,0.0)):
	var scenario : RID
	scenario = get_world_3d().scenario
	
	var new_grass_instance = RenderingServer.instance_create()
	RenderingServer.instance_set_base(new_grass_instance, scattered_mesh.get_rid())
	RenderingServer.instance_geometry_set_visibility_range(new_grass_instance, 0.0, 100.0, 0.0, 0.0, RenderingServer.VISIBILITY_RANGE_FADE_DISABLED)
	RenderingServer.instance_geometry_set_cast_shadows_setting(new_grass_instance, RenderingServer.SHADOW_CASTING_SETTING_OFF)
	RenderingServer.instance_set_transform(new_grass_instance, target_transform)
	RenderingServer.instance_set_scenario(new_grass_instance, scenario)
	#RenderingServer.instance_geometry_set_shader_parameter(new_grass_instance, "normal_vector", normal_vector);
	grass_blade_rids[grass_blade_id] = new_grass_instance

func update_texture_uvs():
	set_instance_shader_parameter("instance_scale", scale.length() * uv_correction_scale)

func equals_with_epsilon(v1, v2, epsilon):
	if (v1.distance_to(v2) < epsilon):
		return true
	return false

func get_random_point_inside_face(vertices,amount) -> Vector3:
	var a = randf_range(0.0,amount)
	var b = randf_range(0.0,amount)
	if  a > b:
		var x = a
		var y = b
		b = x
		a = y
	return vertices[0] * a + vertices[1] * (b - a) + vertices[2] * (1.0 - b)

func barycentric(P, A, B, C):
	# Returns barycentric co-ordinates of point P in triangle ABC
	var mat1 = Basis(A, B, C)
	var det = mat1.determinant()
	var mat2 = Basis(P, B, C)
	var factor_alpha = mat2.determinant()
	var mat3 = Basis(P, C, A)
	var factor_beta = mat3.determinant()
	var alpha = factor_alpha / det;
	var beta = factor_beta / det;
	var gamma = 1.0 - alpha - beta;
	return Vector3(alpha, beta, gamma)

func is_point_in_triangle(point, v1, v2, v3):
	#bc = barycentric(point, v1, v2, v3)
	var bc = barycentric(point, v1, v2, v3)	
	
	if bc.x < 0 or bc.x > 1:
		return false
	if bc.y < 0 or bc.y > 1:
		return false
	if bc.z < 0 or bc.z > 1:
		return false
	return true

func get_face(point, normal, is_global, EPSILON = 0.2):
	mdt.create_from_surface(mesh, 0)
	for idx in range(mdt.get_face_count()):
		var world_normal = (global_transform.basis * mdt.get_face_normal(idx)).normalized()
		
		if !equals_with_epsilon(world_normal, normal, EPSILON):
			continue
		# Normal is the same-ish, so we need to check if the point is on this face
		var v1 = mdt.get_vertex(mdt.get_face_vertex(idx, 0))
		var v2 = mdt.get_vertex(mdt.get_face_vertex(idx, 1))
		var v3 = mdt.get_vertex(mdt.get_face_vertex(idx, 2))
		
		if is_global:
			v1 = global_transform * v1
			v2 = global_transform * v2
			v3 = global_transform * v3

		if is_point_in_triangle(point, v1, v2, v3):
			return idx
	return null

func get_uv_coords(point, face_index, _normal, transform = false):
	# Gets the uv coordinates on the mesh given a point on the mesh and normal
	# these values can be obtained from a raycast
	transform_vertex_to_global = transform
	
	#var face = get_face(point, normal)
	#if face == null:
		#return null
	var v1 = mdt.get_vertex(mdt.get_face_vertex(face_index, 0))
	var v2 = mdt.get_vertex(mdt.get_face_vertex(face_index, 1))
	var v3 = mdt.get_vertex(mdt.get_face_vertex(face_index, 2))
		
	if transform_vertex_to_global:
		v1 = global_transform * v1
		v2 = global_transform * v2
		v3 = global_transform * v3
		
	var bc = barycentric(point, v1, v2, v3)
	var uv1 = mdt.get_vertex_uv(mdt.get_face_vertex(face_index, 0))
	var uv2 = mdt.get_vertex_uv(mdt.get_face_vertex(face_index, 1))
	var uv3 = mdt.get_vertex_uv(mdt.get_face_vertex(face_index, 2))
	return (uv1 * bc.x) + (uv2 * bc.y) + (uv3 * bc.z)

#func get_grass_detail():
	#var detail_multiplier : float = 1.0
	#match(SessionData.settings_data.get("env_detail")):
		#0:
			#detail_multiplier = 0.25
		#1:
			#detail_multiplier = 0.5
		#_:
			#detail_multiplier = 1.0
	#
	#return detail_multiplier

func get_vertex_channel_value(vert_index : int, channel : VertexChannel) -> float:
	match channel:
		VertexChannel.R: 
			return mdt.get_vertex_color(vert_index).r
		VertexChannel.G: 
			return mdt.get_vertex_color(vert_index).g
		VertexChannel.B: 
			return mdt.get_vertex_color(vert_index).b
		VertexChannel.ALL:
			return clamp(mdt.get_vertex_color(vert_index).r + mdt.get_vertex_color(vert_index).g + mdt.get_vertex_color(vert_index).b, 0.0, 1.0)
		_:
			return 0.0
		

func generate_grass():
	remove_all_grass()
	if scattered_mesh == null or enable_foilage == false:
		return
	
	randomize()
	var face_candidates : Array[int]
	var effective_grass_count : int = grass_count * 1.0

	#if Engine.is_editor_hint() == false:
		#effective_grass_count = int(grass_count * get_grass_detail())
	
	var splatmap_image : Image
	if splatmap != null:
		splatmap_image = splatmap.get_image()
		
		if splatmap_image != null:
			splatmap_image.decompress()
	
	if mdt == null:
		mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	
	var _area_accum : float = 0.0
	var _triangle_area_map : Dictionary[float, int]
	
	for i in range(mdt.get_face_count()):
		var vert_id_first = mdt.get_face_vertex(i, 0)
		var vert_id_second = mdt.get_face_vertex(i, 1)
		var vert_id_third = mdt.get_face_vertex(i, 2)
		
		var vert_first : Vector3 = mdt.get_vertex(vert_id_first)
		var vert_second : Vector3 = mdt.get_vertex(vert_id_second)
		var vert_third : Vector3 = mdt.get_vertex(vert_id_third)

		var face_normal = mdt.get_face_normal(i)

		var face_qualified : bool = false
		if face_normal.dot(Vector3.UP) < slope_threshold:
			continue
		
		for face_vert_index in range(3):
			var vert_index = mdt.get_face_vertex(i, face_vert_index)
			if get_vertex_channel_value(vert_index, grass_vertex_channel) > grass_threshold:
				face_qualified = true
				break
		
		if face_qualified == true:
			var face_outline_length = vert_first.distance_to(vert_second) + vert_second.distance_to(vert_third) +   vert_third.distance_to(vert_first)
			for _outline_index in pow(face_outline_length, 1.5):
				face_candidates.append(i)
	
	var accepted_transforms : Array[Transform3D]
	
	for instance_id in range(effective_grass_count):
		#print(random_face_id)
		var random_face_id = face_candidates.pick_random()
		var face_normal = mdt.get_face_normal(random_face_id)
		
		#Getting all the vertices' ids from the current face
		var vert_id_first = mdt.get_face_vertex(random_face_id, 0)
		var vert_id_second = mdt.get_face_vertex(random_face_id, 1)
		var vert_id_third = mdt.get_face_vertex(random_face_id, 2)
		
		var vert_first : Vector3 = mdt.get_vertex(vert_id_first)
		var vert_second : Vector3 = mdt.get_vertex(vert_id_second)
		var vert_third : Vector3 = mdt.get_vertex(vert_id_third)
		
		var random_pos : Vector3 = get_random_point_inside_face([vert_first, vert_second, vert_third], 1.0)
		
		var vert_first_normal : Vector3 = mdt.get_vertex_normal(vert_id_first)
		var vert_second_normal : Vector3 = mdt.get_vertex_normal(vert_id_second)
		var vert_third_normal : Vector3 = mdt.get_vertex_normal(vert_id_third)

		var total_distance = random_pos.distance_to(vert_first) + random_pos.distance_to(vert_second) + random_pos.distance_to(vert_third)
		
		var factor_first = max(total_distance - random_pos.distance_to(vert_first), 0.0)
		var factor_second = max(total_distance - random_pos.distance_to(vert_second), 0.0)
		var factor_third = max(total_distance - random_pos.distance_to(vert_third), 0.0)
		
		var weighted_face_normal : Vector3 = ((vert_first_normal * factor_first) +
		(vert_second_normal  * factor_second) + (vert_third_normal * factor_third)) / 3.0
		
		weighted_face_normal = weighted_face_normal.normalized()
		
		var target_basis = Basis.looking_at((vert_first - vert_second).normalized(), weighted_face_normal) * (uniform_scale + randf_range(-uniform_scale_random,uniform_scale_random))
		var target_transform = global_transform.orthonormalized() * Transform3D(target_basis, random_pos * scale).orthonormalized()
		#multi_mesh.set_instance_transform(instance_id, Transform3D(target_basis, random_pos * mesh_instance.scale))
		var uv_coords : Vector2 = get_uv_coords(random_pos, random_face_id, face_normal, false)
		uv_coords = Vector2(clamp(uv_coords.x, 0.0, 1.0), clamp(uv_coords.y, 0.0, 1.0))
		
		if splatmap_image != null:
			var pixel_coords : Vector2i = Vector2i(uv_coords * Vector2(splatmap_image.get_width()-1, splatmap_image.get_height()-1))

			var pixel_color = splatmap_image.get_pixelv(pixel_coords)
			
			if (pixel_color.r <= 0.5 and pixel_color.g <= 0.5 and pixel_color.b <= 0.5):
				accepted_transforms.append(target_transform)
		else:
			accepted_transforms.append(target_transform)
	
	#multi_mesh.visible_instance_count = accepted_transforms.size()
	grass_blade_rids.resize(accepted_transforms.size())
	for visible_instance_id in range(accepted_transforms.size()):
		var target_transform = accepted_transforms[visible_instance_id]
		#multi_mesh.set_instance_transform(visible_instance_id, target_transform)
		create_grass_blades(visible_instance_id, target_transform, target_transform.basis.y)

func update_shader_mat():
	if splatmap != null or use_vertex_colors == true:
		var new_mat = base_material.duplicate()
		
		if new_mat is ShaderMaterial:
			set_instance_shader_parameter("use_vertex_color", use_vertex_colors)
			new_mat.set_shader_parameter("use_splat_map", splatmap != null)
			new_mat.set_shader_parameter("splat_map", splatmap)
			
			#new_mat.set_shader_parameter("use_mesh_normal", normalmap != null)
			#new_mat.set_shader_parameter("mesh_normal_tex", normalmap)
			
			set_surface_override_material(0, new_mat)
	else:
		set_surface_override_material(0, base_material)
	#mesh_instance.set_surface_override_material(0, base_material)
