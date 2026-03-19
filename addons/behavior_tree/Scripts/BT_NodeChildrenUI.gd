@tool
class_name BT_NodeDataUIWithChildren extends Control

@export var node_name : String
@export var node_icon : Texture

@export_subgroup("UI Nodes")
@export var node_ui : BT_NodeUI
@export var child_container : Container

var bt_node_ui_children : Array[BT_NodeDataUIWithChildren]

func _ready() -> void:
	node_ui.node_name = node_name
	node_ui.node_icon = node_icon
	populate_children_ui()

func populate_children_ui() -> void:
	for child_ui in bt_node_ui_children:
		child_container.add_child(child_ui)

func redraw_lines() -> void:
	pass
