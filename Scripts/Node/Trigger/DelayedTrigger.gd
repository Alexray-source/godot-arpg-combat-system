extends Trigger
class_name DelayTrigger

@export var repeat_count : int = 1
@export var delay_time : float = 1.0
@export var target_trigger : Trigger

func execute(params : Dictionary):
	for repeat_index in range(repeat_count):
		await get_tree().create_timer(delay_time).timeout
		print("delay" + str(repeat_index))
		target_trigger.execute(params)
