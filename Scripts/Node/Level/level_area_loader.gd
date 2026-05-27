class_name LevelAreaLoader extends Node

const PLAYER_SCENE = preload("res://Scenes/Player/player.tscn")

@export var areas : Dictionary[String, PackedScene]
@export var default_area_key : String
@export var areas_holder : Node

var _current_area : Node
var _player : Node3D
var _save_handler : SaveDataHandler
var _save_data : SaveData

func _ready() -> void:
	_save_handler = SaveDataHandler.new()
	_save_data = _save_handler.load_from_disk()
	
	if _save_data == null:
		_save_data = SaveData.new()
	
	GlobalSignals.new_area_reached.connect(load_next_area.bind(true))
	
	if _save_data.checkpoint.is_empty():
		load_next_area(default_area_key, false)
	else:
		load_next_area(_save_data.checkpoint, false)

func load_next_area(area_name : String, save_area : bool = false) -> void:
	if _current_area != null:
		_current_area.queue_free()
	
	if save_area == true:
		_save_data.checkpoint = area_name
		_save_handler.save_to_disk(_save_data)
	
	var area : SubArea = areas.get(area_name).instantiate()
	areas_holder.add_child(area)
	
	if _player == null:
		_player = PLAYER_SCENE.instantiate()
	
		add_child(_player)
		_player.global_transform = area.get_spawn_point_transform()
	
