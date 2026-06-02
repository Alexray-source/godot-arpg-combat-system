extends Node

var _save_handler : SaveDataHandler
var _save_data : SaveData

var save_id : int = 1

func _ready() -> void:
	_save_handler = SaveDataHandler.new()
	load_data_from_disk()

func load_data_from_disk():
	_save_data = _save_handler.load_from_disk(save_id)

func save_current_data_to_disk():
	_save_handler.save_to_disk(_save_data, save_id)

func get_value(data_key : String):
	return _save_data.data.get(data_key)

func set_value(data_key : String, data_value : Variant):
	_save_data.data.set(data_key, data_value)

func delete_data_from_disk():
	_save_handler.delete_from_disk(save_id)
	_save_data = SaveData.new()
	_save_data.data = {}
