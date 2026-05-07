extends Node

const FADE_IN_SCENE : PackedScene = preload("res://Scenes/UI/FadeIn.tscn")

@export var enemy_waves : EnemyWaves
@export var event_triggers : Dictionary[int, Trigger]

func _ready() -> void:
	enemy_waves.new_wave.connect(on_new_wave)

func on_new_wave(wave_number : int):
	print(wave_number)
	if event_triggers.get(wave_number) == null:
		return
	
	event_triggers.get(wave_number).execute({})
