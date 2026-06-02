extends Node

@export var boss_name : String
@export var character : CombatCharacter

func _ready() -> void:
	GlobalSignals.boss_spawned.emit(boss_name, character.start_health, character.max_health)
	character.chr_health_changed.connect(GlobalSignals.boss_health_changed.emit)
	character.chr_died.connect(GlobalSignals.boss_died.emit, CONNECT_ONE_SHOT)
