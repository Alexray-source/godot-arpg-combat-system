class_name EnemyWavesTriggerConnector extends Node

@export var enemy_waves : EnemyWaves
@export var callback_trigger : Trigger

func _ready() -> void:
	enemy_waves.finished.connect(callback_trigger.execute.bind({}))
