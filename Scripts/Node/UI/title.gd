extends Panel

@export var target_scene_path : String

var debounce : bool = false
var save_data_loader : SaveDataHandler

func _ready() -> void:
	save_data_loader = SaveDataHandler.new()
	save_data_loader.save_number = 1

func _input(event: InputEvent) -> void:
	if debounce == true:
		return
	
	if event.is_action("controller_ui_continue"):
		debounce = true
		GlobalSignals.change_scene.emit(target_scene_path)
	
	if event.is_action("controller_ui_back"):
		save_data_loader.delete_from_disk()
