@tool
@abstract class_name BT_CompositeData extends BT_NodeData

@export var children : Array[BT_NodeData]:
	set(value):
		children = value
		children_changed.emit()

signal children_changed
