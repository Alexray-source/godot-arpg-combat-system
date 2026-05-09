extends Trigger
class_name DestroyTrigger

@export var node_to_destroy : Node

func execute(_params : Dictionary):
	node_to_destroy.queue_free()
