extends Trigger
class_name MultiTrigger

@export var triggers : Array[Trigger]

func execute(params : Dictionary):
	for trigger in triggers:
		trigger.execute(params)
