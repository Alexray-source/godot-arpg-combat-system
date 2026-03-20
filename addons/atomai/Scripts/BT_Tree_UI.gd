@tool
class_name BT_Tree_UI extends Control

const NODE_WITH_CHILDREN_UI_SCENE : PackedScene = preload("res://addons/atomai/Scenes/bt_node_children_ui.tscn")

@export var tree_data : BT_CompositeData:
	set(value):
		tree_data = value
		rebuild_ui()

@export var tree_container : VBoxContainer

var tree_root_ui : BT_NodeDataUIWithChildren
var dragging : bool = false
var ui_nodes_associated_data : Dictionary[BT_NodeDataUIWithChildren, BT_NodeData]
var lines : Array[Line2D]

var zoom_scale : float = 1.0


signal node_selected(node_ui : BT_NodeDataUIWithChildren)

func create_node_ui(node_data : BT_NodeData):
	if node_data == null:
		return
	
	var node = node_data
	var node_ui : BT_NodeDataUIWithChildren = NODE_WITH_CHILDREN_UI_SCENE.instantiate()
	
	if node_data.resource_name.is_empty():
		node_ui.node_name = node_data.get_script().get_global_name()
	else:
		node_ui.node_name = node_data.resource_name
	
	node_ui.node_icon = EditorInterface.get_editor_theme().get_icon("Node", &"EditorIcons")
	
	ui_nodes_associated_data.set(node_ui, node_data)
	node_ui.branch_root_node_selected.connect(func():
		node_selected.emit(node_ui)
	)
	
	return node_ui

func create_tree_branch_ui(composite : BT_CompositeData):
	if composite == null:
		return
	
	var node_ui : BT_NodeDataUIWithChildren = NODE_WITH_CHILDREN_UI_SCENE.instantiate()
	
	if composite.resource_name.is_empty():
		node_ui.node_name = composite.get_script().get_global_name()
	else:
		node_ui.node_name = composite.resource_name
	
	node_ui.node_icon = EditorInterface.get_editor_theme().get_icon("Object", &"EditorIcons")
	
	ui_nodes_associated_data.set(node_ui, composite)
	node_ui.branch_root_node_selected.connect(func():
		node_selected.emit(node_ui)
	)
	
	var created_children_ui : Array[BT_NodeDataUIWithChildren]
	
	for node_data in composite.children:
		var child_node_ui : BT_NodeDataUIWithChildren
		
		if node_data is BT_CompositeData:
			child_node_ui = create_tree_branch_ui(node_data)
		else:
			child_node_ui = create_node_ui(node_data)
		
		if child_node_ui == null:
			continue
		
		created_children_ui.append(child_node_ui)
	
	node_ui.bt_node_ui_children = created_children_ui
	#node.children = created_children
	if composite.children_changed.is_connected(rebuild_ui) == false:
		composite.children_changed.connect(rebuild_ui)
	
	return node_ui

func _ready() -> void:
	rebuild_ui()
	
	tree_container.sort_children.connect(func():
		#tree_root_ui.redraw_lines()
		redraw_lines()
	)
	
	node_selected.connect(func(selected_node_ui : BT_NodeDataUIWithChildren):
		for ui_node in ui_nodes_associated_data:
			ui_node.node_ui.update_style(false)
		
		selected_node_ui.node_ui.update_style(true)
	)

func rebuild_ui() -> void:
	if tree_container == null:
		return
	
	for child : Node in tree_container.get_children():
		child.queue_free()
	
	if tree_data == null:
		return
		
	ui_nodes_associated_data.clear()
	
	tree_root_ui = create_tree_branch_ui(tree_data)
	
	if tree_root_ui != null:
		tree_container.add_child(tree_root_ui)
	#tree_root_ui.redraw_lines()

func redraw_lines() -> void:
	#print("redrawing lines")
	for line in lines:
		#print(line.position)
		line.queue_free()
	
	lines.clear()
	
	if tree_root_ui != null:
		draw_lines_branch(tree_root_ui)

##TODO
##Put this either in the BT_NodeChildrenUI script or put it in a seperate object for reuse/modularity
func draw_lines_branch(node_children_ui : BT_NodeDataUIWithChildren) -> void:
	var tree_ui_center : Vector2 = tree_root_ui.global_position + (tree_container.get_global_rect().size * tree_container.pivot_offset_ratio)
	
	for child_ui in node_children_ui.bt_node_ui_children:
		var root_branch_origin : Vector2 = node_children_ui.node_ui.global_position - tree_ui_center
		var child_branch_origin : Vector2 = child_ui.node_ui.global_position - tree_ui_center
		
		var root_node_line_offset : Vector2 = (Vector2(node_children_ui.node_ui.size.x * 0.5, node_children_ui.node_ui.size.y)* tree_container.scale.x)
		var child_node_line_offset : Vector2 = (Vector2(child_ui.node_ui.size.x * 0.5, 0.0) * tree_container.scale.x)
		
		var line = Line2D.new()
		line.width = 2.0
		line.default_color = Color(0.406, 0.406, 0.406, 1.0)
		line.antialiased = true
		line.global_position = tree_container.position + (tree_container.size * tree_container.pivot_offset_ratio)
		#line.global_position = Vector2(-tree_container.size.x * 0.5, -tree_container.size.y * 0.5)
		#line.top_level = true
		add_child(line)
		#line.add_point(root_branch_origin + root_node_line_offset)
		#line.add_point(child_branch_origin + child_node_line_offset)
		
		###Fancier Lines
		line.add_point(root_branch_origin + root_node_line_offset)
		line.add_point(root_branch_origin + root_node_line_offset + Vector2(0,75.0 * tree_container.scale.x))
		line.add_point(Vector2(child_branch_origin.x  + child_node_line_offset.x, root_branch_origin.y + root_node_line_offset.y) + Vector2(0,75.0 * tree_container.scale.x))
		line.add_point(child_branch_origin + child_node_line_offset)
		
		lines.append(line)
		
		draw_lines_branch(child_ui)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			redraw_lines()
		elif event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			zoom_scale = clampf(zoom_scale + 0.1, 0.1, 3.0)
			tree_container.scale = Vector2(zoom_scale,zoom_scale)
			redraw_lines()
		elif event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			zoom_scale = clampf(zoom_scale - 0.1, 0.1, 3.0)
			tree_container.scale = Vector2(zoom_scale,zoom_scale)
			redraw_lines()
	
	elif event is InputEventMouseMotion:
		if dragging == true:
			tree_container.position += event.screen_relative
			redraw_lines()
			#tree_root_ui.redraw_lines()
