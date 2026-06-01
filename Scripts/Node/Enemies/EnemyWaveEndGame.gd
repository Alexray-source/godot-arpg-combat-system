extends Node

const FADE_IN_SCENE : PackedScene = preload("res://Scenes/UI/FadeIn.tscn")

@export var enemy_waves : EnemyWaves
@export var target_scene_path : String
@export var bgm_changer : BgmChanger

func _ready() -> void:
	enemy_waves.finished.connect(transition, CONNECT_ONE_SHOT)

func transition():
	await get_tree().create_timer(1.5).timeout
	
	bgm_changer.execute({})
	
	var fade_in : Control = FADE_IN_SCENE.instantiate()
	fade_in.top_level = true
	add_child(fade_in)
	await get_tree().create_timer(2.0).timeout
	
	GlobalSignals.change_scene.emit(target_scene_path)
