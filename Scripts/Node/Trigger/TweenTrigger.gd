extends Trigger
class_name TweenTrigger

@export var target_node : Node
@export var tweens_data : Array[FlexibleTween]
@export var finished_trigger_callback : Trigger

signal tweens_finished

func finish():
	tweens_finished.emit()
	if finished_trigger_callback != null:
		finished_trigger_callback.execute({})

func execute(_params : Dictionary):
	for tween_data in tweens_data:
		var tween : Tween = tween_data.play(target_node)
		
		if tweens_data.find(tween_data) == tweens_data.size()-1 and tween.finished.is_connected(finish) == false:
			tween.finished.connect(finish, CONNECT_ONE_SHOT)
