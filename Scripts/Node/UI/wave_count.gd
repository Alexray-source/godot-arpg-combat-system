extends Control

@export var label : Label
@export var wave_number : int = 0
@export var wave_total : int = 1

func _ready() -> void:
	label.text = "%d / %d" %  [wave_number, wave_total]
