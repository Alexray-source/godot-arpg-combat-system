extends Panel

@export var target_scene_path : String

var debounce : bool = false

func _input(event: InputEvent) -> void:
	if debounce == true:
		return
	
	if event.is_action_pressed("controller_ui_continue"):
		debounce = true
		GlobalSignals.change_scene.emit(target_scene_path)
	
	if event.is_action_pressed("controller_ui_back"):
		PersistentData.delete_data_from_disk()
