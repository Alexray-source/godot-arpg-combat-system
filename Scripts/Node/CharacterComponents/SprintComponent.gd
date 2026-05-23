class_name SprintComponent extends CharacterComponent

@export var sprint_speed : float

var enable_sprint : bool = false
var _cached_speed : float

func _ready() -> void:
	_cached_speed = character.move_speed

func action() -> void:
	if enable_sprint == true:
		character.move_speed = sprint_speed
	else:
		character.move_speed = _cached_speed
