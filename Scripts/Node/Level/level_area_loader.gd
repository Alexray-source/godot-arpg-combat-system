class_name LevelAreaLoader extends Node

const PLAYER_SCENE = preload("res://Scenes/Player/player.tscn")

@export var areas : Dictionary[String, PackedScene]
@export var default_area_key : String
@export var areas_holder : Node

var _current_area : Node
var _player : Node3D
var _checkpoint : String

func _ready() -> void:
	_checkpoint = default_area_key
	
	GlobalSignals.new_area_reached.connect(load_next_area.bind(true))
	if PersistentData.get_value("checkpoint") != null:
		_checkpoint = PersistentData.get_value("checkpoint")
	
	load_next_area(_checkpoint, false)

func load_next_area(area_name : String, save_area : bool = false) -> void:
	if _current_area != null:
		_current_area.queue_free()
	
	if save_area == true:
		PersistentData.set_value("checkpoint", area_name)
		PersistentData.save_current_data_to_disk()
	
	var area : SubArea = areas.get(area_name).instantiate()
	areas_holder.add_child(area)
	
	if _player == null:
		_player = PLAYER_SCENE.instantiate()
	
		add_child(_player)
		_player.global_transform = area.get_spawn_point_transform()
	
