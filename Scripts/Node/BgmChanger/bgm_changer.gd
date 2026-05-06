class_name BgmChanger extends Node

@export var auto_start : bool = false
@export var bgm : AudioStream
@export var crossfade_time : float = 0.5

func _ready() -> void:
	if auto_start == false:
		return
	
	change_bgm()

func change_bgm():
	GlobalSignals.change_bgm.emit(bgm, crossfade_time)
