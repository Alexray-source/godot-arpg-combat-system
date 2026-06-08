@tool
extends EditorPlugin

var dock : EditorDock
var dock_content : SplatmapBrushEditorDock
var brush_3d_indicator : Decal
var brush_world_pos : Vector3
var drawing_viewport : SubViewport
var cached_bg_rect : TextureRect
var current_terrain_mesh : TerrainMeshInstance

const DEFAULT_BRUSH = preload("res://addons/splatmapterrainmeshpainter/tex/radial.png")

const COLOR_OPTIONS : Dictionary = {
	dock_content.DrawChannel.RED : Color.RED,
	dock_content.DrawChannel.GREEN : Color.GREEN,
	dock_content.DrawChannel.BLUE : Color.BLUE,
	dock_content.DrawChannel.BLACK : Color.BLACK
}

var brush_color = COLOR_OPTIONS[dock_content.DrawChannel.RED]

func _enter_tree() -> void:
	EditorInterface.get_selection().selection_changed.connect(node_selection_changed)

func _handles(object: Object) -> bool:
	if object != null and object is TerrainMeshInstance:
		return true
	return false

#func remove_dock_content():
	#if dock_content != null:
		#remove_control_from_dock_contents(dock_content)
		#dock_content.free()
#
#func add_dock_content():
	#dock_content = preload("res://addons/splatmapterrainmeshpainter/scenes/brush_editor_dock_content.tscn").instantiate() as SplatmapBrushEditorDock
	#add_control_to_dock_content(EditorPlugin.DOCK_SLOT_LEFT_UR, dock_content)
	#
	#dock_content.apply_btn_pressed.connect(apply_viewport_to_mesh)

func build_dock():
	if dock != null:
		return
	
	dock = EditorDock.new()
	dock.title = "Splatmap Mesh Painter"
	dock.dock_icon = preload("./icons/draw.svg")
	dock.default_slot = EditorDock.DOCK_SLOT_LEFT_UR
	dock_content = preload("res://addons/splatmapterrainmeshpainter/scenes/brush_editor_dock.tscn").instantiate() as SplatmapBrushEditorDock
	
	dock.add_child(dock_content)
	add_dock(dock)
	
	#add_control_to_dock_content(EditorPlugin.DOCK_SLOT_LEFT_UR, dock_content)
	#
	dock_content.apply_btn_pressed.connect(apply_viewport_to_mesh)

func destroy_dock():
	if dock == null:
		return
	
	remove_dock(dock)
	dock.queue_free()
	dock = null
	dock_content = null

func clean_up():
	if current_terrain_mesh != null:
		restore_cached_splatmap()
		
		if current_terrain_mesh.new_splat_generated.is_connected(node_selection_changed) == true:
			current_terrain_mesh.new_splat_generated.disconnect(node_selection_changed)
		
		current_terrain_mesh = null
	
	destroy_dock()
	if brush_3d_indicator != null:
		brush_3d_indicator.queue_free()
	
	if drawing_viewport != null:
		drawing_viewport.queue_free()

func restore_cached_splatmap():
	if current_terrain_mesh.splatmap is ViewportTexture:
		current_terrain_mesh.splatmap = cached_bg_rect.texture
		current_terrain_mesh.update_shader_mat()

func init_viewport():
	drawing_viewport = SubViewport.new()
	drawing_viewport.size = Vector2i(256,256)
	get_tree().edited_scene_root.add_child(drawing_viewport)
	cached_bg_rect = TextureRect.new()
	cached_bg_rect.texture = current_terrain_mesh.splatmap.duplicate()
	
	drawing_viewport.add_child(cached_bg_rect)
	cached_bg_rect.size = drawing_viewport.size
	cached_bg_rect.position = Vector2(0,0)
	current_terrain_mesh.splatmap = drawing_viewport.get_viewport().get_texture()
	current_terrain_mesh.update_shader_mat()

func draw_on_viewport(color, uv_coords, draw_size):
	if drawing_viewport != null:
		var position = uv_coords * Vector2(drawing_viewport.size)
		
		var brush = TextureRect.new()
		brush.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		brush.texture = DEFAULT_BRUSH
		brush.stretch_mode = TextureRect.STRETCH_SCALE
		brush.size = Vector2(draw_size*0.5,draw_size*0.5)
		brush.self_modulate = color
		brush.position = position - (brush.size * 0.5)
		brush.reset_physics_interpolation()
		#print(brush.position)
		drawing_viewport.add_child(brush)

func apply_viewport_to_mesh():
	print(current_terrain_mesh != null and current_terrain_mesh.splatmap != null)
	if current_terrain_mesh != null and current_terrain_mesh.splatmap != null:
		drawing_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		var converted_img = drawing_viewport.get_viewport().get_texture().get_image()
		converted_img.generate_mipmaps()
		
		var portable_compressed_texture = PortableCompressedTexture2D.new()
		portable_compressed_texture.keep_compressed_buffer = true
		portable_compressed_texture.create_from_image(converted_img, PortableCompressedTexture2D.COMPRESSION_MODE_BASIS_UNIVERSAL)
		current_terrain_mesh.splatmap = portable_compressed_texture
		current_terrain_mesh.update_shader_mat()
		if drawing_viewport != null:
			drawing_viewport.queue_free()
		init_viewport()
		#cached_bg_rect.texture = current_terrain_mesh.splatmap

func mouse_raycast(viewport_camera : Camera3D, mouse_pos : Vector2):
	var dropPlane  = Plane(Vector3(0, 1, 0), 0)
	
	var from = viewport_camera.project_ray_origin(mouse_pos)
	var to = from + viewport_camera.project_ray_normal(mouse_pos) * viewport_camera.far
	var cursor_plane_pos = dropPlane.intersects_ray(from, to)
	
	var space_state : PhysicsDirectSpaceState3D = EditorInterface.get_edited_scene_root().get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	return space_state.intersect_ray(query)

func node_selection_changed():
	var selected_nodes = EditorInterface.get_selection().get_selected_nodes()
	
	if selected_nodes.size() > 0 and selected_nodes[0] is TerrainMeshInstance:
		if selected_nodes[0] != current_terrain_mesh:
			restore_cached_splatmap()
		print(selected_nodes[0])
		current_terrain_mesh = selected_nodes[0]
		
		if current_terrain_mesh.new_splat_generated.is_connected(node_selection_changed) == false:
			current_terrain_mesh.new_splat_generated.connect(node_selection_changed)
		
		if drawing_viewport != null:
			drawing_viewport.queue_free()
		init_viewport()

		if dock_content == null:
			build_dock()
			brush_3d_indicator = preload("res://addons/splatmapterrainmeshpainter/scenes/brush_decal.tscn").instantiate() as Decal
			get_tree().edited_scene_root.add_child(brush_3d_indicator)
	elif selected_nodes.size() == 0 or (selected_nodes[0] is not TerrainMeshInstance):
		clean_up()

func _forward_3d_gui_input(viewport_camera: Camera3D, event: InputEvent) -> int:
	if brush_3d_indicator == null or dock_content == null or current_terrain_mesh == null or drawing_viewport == null:
		return AFTER_GUI_INPUT_PASS
	
	brush_3d_indicator.visible = dock_content.draw_mode == dock_content.DrawMode.DRAW
	var captured_event = false
	if dock_content.draw_mode == dock_content.DrawMode.DRAW:
		if event is InputEventMouseMotion:
			var mouse_pos = viewport_camera.get_viewport().get_mouse_position()
			var result = mouse_raycast(viewport_camera, mouse_pos)
			
			var brush_uv_space_size : Vector2 = Vector2(dock_content.draw_size , dock_content.draw_size) / Vector2(drawing_viewport.size)
			
			if result.size() > 0:
				var collider : Node3D = result.collider
				var collider_scale = collider.global_basis.get_scale().length()
				
				brush_world_pos = result.position + (viewport_camera.project_ray_normal(mouse_pos) * -0.1)
				brush_3d_indicator.global_position = brush_world_pos
				brush_3d_indicator.size = Vector3(brush_uv_space_size.x * collider_scale,25.0,brush_uv_space_size.y * collider_scale) * 17.5
			
				if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
					captured_event = true
					brush_color = COLOR_OPTIONS[dock_content.current_draw_channel]

					var face_index = current_terrain_mesh.get_face(result.position, result.normal, true, 0.001)
					#print(face_index)
					var uv_coords = current_terrain_mesh.get_uv_coords(result.position, face_index, result.normal, true)
					#print(uv_coords)
					draw_on_viewport(brush_color, uv_coords, dock_content.draw_size)
					drawing_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
					#await RenderingServer.frame_post_draw
					current_terrain_mesh.splatmap = drawing_viewport.get_viewport().get_texture()
			#else:
				#return AFTER_GUI_INPUT_PASS
			
		
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
				#var mouse_pos = viewport_camera.get_viewport().get_mouse_position()
				#var result = mouse_raycast(viewport_camera, mouse_pos)
				#
				#if result.size() > 0:
					#var face_index = current_terrain_mesh.get_face(result.position, result.normal, true)
					##print(face_index)
					#var uv_coords = current_terrain_mesh.get_uv_coords(result.position, face_index, result.normal, true)
					##print(uv_coords)
					#draw_on_viewport(brush_color, uv_coords, dock_content.draw_size)
					#
					#drawing_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
					#await RenderingServer.frame_post_draw
					#current_terrain_mesh.splatmap = drawing_viewport.get_viewport().get_texture()
			
				captured_event = true
	
	if captured_event == true:
		return AFTER_GUI_INPUT_STOP
	return AFTER_GUI_INPUT_PASS

func _exit_tree() -> void:
	clean_up()
