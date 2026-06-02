extends Control

@export var boss_bar : ProgressBar
@export var boss_label : Label
@export var boss_spawned_trigger : Trigger
@export var boss_died_trigger : Trigger

func _ready() -> void:
	GlobalSignals.boss_spawned.connect(on_boss_spawned)
	GlobalSignals.boss_died.connect(on_boss_died)
	
	GlobalSignals.boss_health_changed.connect(on_boss_health_changed)

func on_boss_spawned(boss_name : String, start_health : int, max_health : int):
	boss_bar.value = start_health/float(max_health)
	boss_label.text = boss_name
	boss_spawned_trigger.execute({})

func on_boss_died():
	boss_died_trigger.execute({})

func on_boss_health_changed(new_health : int, max_health : int):
	boss_bar.value = new_health/float(max_health)
