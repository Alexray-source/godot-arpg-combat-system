class_name BgmChanger extends Trigger

@export var bgm : AudioStream
@export var crossfade_time : float = 0.5

func execute(_params : Dictionary):
	GlobalSignals.change_bgm.emit(bgm, crossfade_time)
