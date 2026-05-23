extends Node

const WAVE_COUNTER_UI : PackedScene = preload("res://Scenes/UI/wave_count.tscn")

@export var enemy_waves : EnemyWaves

func _ready() -> void:
	enemy_waves.new_wave.connect(on_new_wave)

func on_new_wave(new_wave_number : int):
	var wave_counter_ui : WaveCounterUI = WAVE_COUNTER_UI.instantiate()
	wave_counter_ui.wave_number = new_wave_number
	wave_counter_ui.wave_total = enemy_waves.waves_collection.waves.size()
	
	add_child(wave_counter_ui)
	
