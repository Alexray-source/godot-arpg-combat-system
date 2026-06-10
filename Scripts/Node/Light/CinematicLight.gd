extends Light3D
class_name CinematicLight

enum FlarePosMode {
	GLOBAL,
	RELATIVE_TO_CAMERA
}

class FlareMetaData:
	var flare_pos : Vector3
	var flare_mode : FlarePosMode
	
	func _init(_flare_pos : Vector3, _flare_mode = FlarePosMode.GLOBAL) -> void:
		flare_pos = _flare_pos
		flare_mode = _flare_mode


func get_flare_data() -> FlareMetaData:
	return FlareMetaData.new(global_position)

func get_flare_size() -> float:
	return light_energy
