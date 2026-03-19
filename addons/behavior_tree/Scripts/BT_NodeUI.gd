@tool
class_name BT_NodeUI extends Control

@export var node_name : String:
	set(value):
		node_name = value
		name_label.text = value
@export var node_icon : Texture2D:
	set(value):
		node_icon = value
		icon_rect.texture = value

@export_subgroup("UI Nodes")
@export var icon_rect : TextureRect
@export var name_label : Label

func _ready() -> void:
	name_label.text = node_name
	icon_rect.texture = node_icon
