@tool
class_name BT_NodeUI extends Control

const DEFAULT_STYLE = preload("res://addons/atomai/Styles/node_default.tres")
const SELECTED_STYLE = preload("res://addons/atomai/Styles/node_selected.tres")

@export var node_name : String:
	set(value):
		node_name = value
		update_label(value)
@export var node_icon : Texture2D:
	set(value):
		node_icon = value
		icon_rect.texture = value

@export_subgroup("UI Nodes")
@export var node_container : PanelContainer
@export var icon_rect : TextureRect
@export var name_label : Label

#var associated_node_data : BT_NodeData
signal node_selected

func _ready() -> void:
	update_label(node_name)
	icon_rect.texture = node_icon
	update_style(false)

func update_label(text_value : String):
	name_label.custom_minimum_size = Vector2(clamp(text_value.length() * 8.0, 64.0, 128.0), 0.0)
	name_label.text = text_value

func update_style(is_selected : bool):
	if is_selected == true:
		node_container.add_theme_stylebox_override("panel", SELECTED_STYLE)
	else:
		node_container.add_theme_stylebox_override("panel", DEFAULT_STYLE)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed == true:
			node_selected.emit()
