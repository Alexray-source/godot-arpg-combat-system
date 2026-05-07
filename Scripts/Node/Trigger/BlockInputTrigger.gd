class_name BlockInputTrigger extends Trigger

@export var block_input : bool = true

func execute(_params : Dictionary):
	GlobalSignals.plr_input_state_changed.emit(not block_input)
