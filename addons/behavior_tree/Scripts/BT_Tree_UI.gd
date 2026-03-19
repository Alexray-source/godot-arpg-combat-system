extends Control

const NODE_WITH_CHILDREN_UI_SCENE : PackedScene = preload("res://addons/behavior_tree/Scenes/bt_node_children_ui.tscn")

@export var tree_data : BT_CompositeData
@export var tree_container : VBoxContainer

var dragging : bool = false

func create_node_ui(node_data : BT_NodeData):
	var node = node_data
	var node_ui : BT_NodeDataUIWithChildren = NODE_WITH_CHILDREN_UI_SCENE.instantiate()
	
	node_ui.node_name = node_data.get_script().get_global_name()
	return node_ui

func create_tree_branch_ui(composite : BT_CompositeData):
	var node_ui : BT_NodeDataUIWithChildren = NODE_WITH_CHILDREN_UI_SCENE.instantiate()
	
	node_ui.node_name = composite.get_script().get_global_name()
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
	
	return node_ui

func _ready() -> void:
	var tree_ui = create_tree_branch_ui(tree_data)
	tree_container.add_child(tree_ui)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			print(event.pressed)
		elif event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			tree_container.scale = (tree_container.scale + Vector2(0.1, 0.1)).clampf(0.1, 3.0)
		elif event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			tree_container.scale = (tree_container.scale - Vector2(0.1, 0.1)).clampf(0.1, 3.0)
		
	elif event is InputEventMouseMotion:
		if dragging == true:
			tree_container.position += event.screen_relative
