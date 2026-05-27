class_name AreaReachedTrigger extends Trigger

@export var new_area_name : String

func execute(_params : Dictionary):
	GlobalSignals.new_area_reached.emit(new_area_name)
