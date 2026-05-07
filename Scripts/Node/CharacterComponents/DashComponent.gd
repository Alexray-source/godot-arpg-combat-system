class_name DashComponent extends CharacterComponent

@export var dash_time : float = 0.5
@export var dash_intensity : float = 10.0
@export var dash_dir : Vector3
var timer : SceneTreeTimer

signal dash_ended

func stop_dash() -> void:
	#character.velocity = Vector3.ZERO
	timer = null
	dash_ended.emit()

func action() -> void:
	character.velocity = dash_dir * dash_intensity
	if timer != null:
		timer.time_left = dash_time
	else:
		timer = get_tree().create_timer(dash_time)
		timer.timeout.connect(stop_dash)
	
