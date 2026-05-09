class_name ToggleHudTrigger extends Trigger

@export var is_visible : bool = true

func execute(_params : Dictionary):
	GlobalSignals.plr_hud_state_changed.emit(is_visible)
