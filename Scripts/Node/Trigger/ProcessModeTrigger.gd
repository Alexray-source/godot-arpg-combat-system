class_name ProcessModeTrigger extends Trigger

@export var target_node : Node
@export var new_mode : Node.ProcessMode

func execute(_params : Dictionary):
	target_node.process_mode = new_mode
