@tool
class_name InvertedProgressBar extends ProgressBar

@export var regular_value : float:
	set(_value):
		regular_value = clampf(_value, min_value, max_value)
		value = max_value-regular_value
