@tool
extends EditorPlugin

var dock : EditorDock
var dock_content : TextureArrayCreatorDock

#func remove_dock():
	#if dock != null:
		#remove_control_from_docks(dock)
		#dock.free()

#func add_dock():
	#dock = preload("res://addons/texture_2d_array_creator/scenes/dock.tscn").instantiate() as TextureArrayCreatorDock
	#add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, dock)

func _enter_tree() -> void:
	dock = EditorDock.new()
	dock.title = "Texture Array Creator"
	dock.default_slot = EditorDock.DOCK_SLOT_LEFT_UL
	
	dock_content = preload("res://addons/texture_2d_array_creator/scenes/dock.tscn").instantiate() as TextureArrayCreatorDock
	dock.add_child(dock_content)
	add_dock(dock)


func _exit_tree() -> void:
	remove_dock(dock)
	dock.queue_free()
	dock = null
