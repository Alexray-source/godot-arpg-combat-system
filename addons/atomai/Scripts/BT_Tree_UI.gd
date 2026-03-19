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

signal node_selected(node_ui : BT_NodeDataUIWithChildren)

func create_node_ui(node_data : BT_NodeData):
	var node = node_data
	var node_ui : BT_NodeDataUIWithChildren = NODE_WITH_CHILDREN_UI_SCENE.instantiate()
	
	node_ui.node_name = node_data.get_script().get_global_name()
	
	ui_nodes_associated_data.set(node_ui, node_data)
	node_ui.branch_root_node_selected.connect(func():
		node_selected.emit(node_ui)
	)
	
	return node_ui

func create_tree_branch_ui(composite : BT_CompositeData):
	var node_ui : BT_NodeDataUIWithChildren = NODE_WITH_CHILDREN_UI_SCENE.instantiate()
	
	node_ui.node_name = composite.get_script().get_global_name()
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
		
		created_children_ui.append(child_node_ui)
	
	node_ui.bt_node_ui_children = created_children_ui
	#node.children = created_children
	if composite.children_changed.is_connected(rebuild_ui) == false:
		composite.children_changed.connect(rebuild_ui)
	
	return node_ui

func _ready() -> void:
	rebuild_ui()

func rebuild_ui() -> void:
	if tree_container == null:
		return
	
	for child : Node in tree_container.get_children():
		child.queue_free()
	
	if tree_data == null:
		return
		
	ui_nodes_associated_data.clear()
	
	tree_root_ui = create_tree_branch_ui(tree_data)
	tree_container.add_child(tree_root_ui)
	
	tree_root_ui.child_entered_tree.connect(func(node):
		tree_root_ui.redraw_lines()
	)
	#tree_root_ui.redraw_lines()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			dragging = event.pressed
		#elif event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			#tree_container.scale = (tree_container.scale + Vector2(0.1, 0.1)).clampf(0.1, 3.0)
		#elif event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			#tree_container.scale = (tree_container.scale - Vector2(0.1, 0.1)).clampf(0.1, 3.0)
	#
	elif event is InputEventMouseMotion:
		if dragging == true:
			tree_container.position += event.screen_relative
			tree_root_ui.redraw_lines()
