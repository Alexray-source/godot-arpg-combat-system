@tool
extends EditorPlugin

var tree_view : BT_Tree_UI
var dock : EditorDock

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

func setup_tree_ui():
	tree_view.node_selected.connect(on_ui_node_selected)

func on_ui_node_selected(node_ui : BT_NodeDataUIWithChildren):
	var associated_data : BT_NodeData = tree_view.ui_nodes_associated_data.get(node_ui)
	EditorInterface.get_inspector().edit(associated_data)

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		tree_view = load("res://addons/atomai/Scenes/bt_tree_data_visualizer.tscn").instantiate()
		setup_tree_ui()
		
		dock = EditorDock.new()
		dock.title = "AtomAI Behavior Tree"
		dock.default_slot = EditorDock.DOCK_SLOT_BOTTOM
		dock.clip_contents = true
		dock.add_child(tree_view)
		
		add_dock(dock)


func _exit_tree() -> void:
	remove_dock(dock)
	dock.queue_free()

func _handles(object: Object) -> bool:
	return object is BT_CompositeData

func _edit(object: Object) -> void:
	if object is not BT_CompositeData:
		return
	
	tree_view.tree_data = object
	make_bottom_panel_item_visible(tree_view)
