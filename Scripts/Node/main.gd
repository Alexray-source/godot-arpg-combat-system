extends Node

const LOADING_SCREEN_SCENE : PackedScene = preload("res://Scenes/UI/LoadingScreen.tscn")

@export var scene_path : String
var current_scene : Node
var is_loading : bool = false
var load_screen : LoadingScreen

signal scene_loaded

func _ready() -> void:
	load_scene(scene_path)
	scene_loaded.connect(on_scene_loaded)
	
	GlobalSignals.restart_scene.connect(restart_scene)

func restart_scene():
	load_scene(scene_path)

func load_scene(_path) -> void:
	load_screen = LOADING_SCREEN_SCENE.instantiate()
	add_child(load_screen)
	load_screen.load_start()
	
	if current_scene != null and current_scene.is_inside_tree():
		current_scene.queue_free()
	ResourceLoader.load_threaded_request(scene_path)
	is_loading = true
	set_process(true)

func on_scene_loaded():
	load_screen.load_finished()
	load_screen.load_animation_finished.connect(func():
		load_screen.queue_free()
		load_screen = null
	, CONNECT_ONE_SHOT)
	
	var loaded_packed_scene : PackedScene = ResourceLoader.load_threaded_get(scene_path)
	current_scene = loaded_packed_scene.instantiate()
	add_child(current_scene)

func _process(_delta: float) -> void:
	var load_progress : ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(scene_path)
	
	if load_progress == ResourceLoader.THREAD_LOAD_LOADED:
		set_process(false)
		is_loading = false
		scene_loaded.emit()
	
