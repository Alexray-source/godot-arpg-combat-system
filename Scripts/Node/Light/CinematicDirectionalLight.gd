extends CinematicLight
class_name CinematicDirectionalLight

func get_flare_data() -> FlareMetaData:
	return FlareMetaData.new(global_position, FlarePosMode.RELATIVE_TO_CAMERA)
