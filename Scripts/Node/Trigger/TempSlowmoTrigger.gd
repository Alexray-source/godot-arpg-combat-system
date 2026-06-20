extends Trigger
class_name TempSlowmoTrigger

@export var time_factor : float = 0.1
@export var slowmo_time : float = 1.0

func execute(_params : Dictionary):
	Engine.time_scale = time_factor
	await get_tree().create_timer(slowmo_time, true, false, true).timeout
	Engine.time_scale = 1.0
