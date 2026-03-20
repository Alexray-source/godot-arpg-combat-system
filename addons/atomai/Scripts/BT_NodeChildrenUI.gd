@tool
class_name BT_NodeDataUIWithChildren extends Control

@export var node_name : String
@export var node_icon : Texture

@export_subgroup("UI Nodes")
@export var node_ui : BT_NodeUI
@export var child_container : Container

signal branch_root_node_selected

var bt_node_ui_children : Array[BT_NodeDataUIWithChildren]
var lines : Array[Line2D]

func _ready() -> void:
	node_ui.node_name = node_name
	node_ui.node_icon = node_icon
	
	node_ui.node_selected.connect(func():
		branch_root_node_selected.emit()
	)
	
	#child_container.resized.connect(redraw_lines)
	
	populate_children_ui()

func populate_children_ui() -> void:
	for child_ui in bt_node_ui_children:
		#child_ui.resized.connect(redraw_lines)
		child_container.add_child(child_ui)
	
	#redraw_lines()

#func redraw_lines() -> void:
	#print("redrawing lines")
	#for line in lines:
		#line.queue_free()
	#
	#lines.clear()
	#
	#for child_ui : BT_NodeDataUIWithChildren in child_container.get_children():
		#var line = Line2D.new()
		#line.width = 2.0
		#line.default_color = Color(0.406, 0.406, 0.406, 1.0)
		#line.antialiased = true
		#line.add_point(Vector2(node_ui.size.x*0.5, node_ui.size.y))
		##print((node_ui.global_position - child_ui.global_position))
		#line.add_point((child_ui.global_position - node_ui.global_position) + Vector2(node_ui.size.x*0.5, 0.0))
		#
		#lines.append(line)
		#node_ui.add_child(line)
		
		#child_ui.redraw_lines()
	
