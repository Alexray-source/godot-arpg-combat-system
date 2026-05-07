extends Node
class_name Trigger

@export var auto_trigger = false

func _ready() -> void:
	if auto_trigger == true:
		execute({})

func execute(_params : Dictionary):
	pass
