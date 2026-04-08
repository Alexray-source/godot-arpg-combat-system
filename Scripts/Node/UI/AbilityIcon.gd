class_name AbilityIcon extends TextureRect

var fill_progress_factor : float:
	set(_value):
		fill_progress_factor = _value
		update_bar(_value)

@export var invert_visual_progress : bool

@export_subgroup("Nodes")
@export var progress_bar : ProgressBar

func update_bar(new_fill_factor : float):
	if progress_bar == null:
		return
	
	if invert_visual_progress == true:
		progress_bar.value = 1.0 - new_fill_factor
	else:
		progress_bar.value = new_fill_factor
