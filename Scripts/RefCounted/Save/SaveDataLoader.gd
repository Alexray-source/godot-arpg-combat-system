class_name SaveDataHandler extends RefCounted

var save_number : int = 1

func load_from_disk() -> SaveData:
	var save_file = FileAccess.open("user://save" + str(save_number), FileAccess.READ)
	
	if save_file == null:
		return null
	
	var data = save_file.get_var(false)
	
	if data is not Dictionary:
		return null
	
	var new_save_data : SaveData = SaveData.new()
	
	for data_key in data:
		new_save_data.set(data_key, data[data_key])
		
	return new_save_data

func save_to_disk(save_data : SaveData):
	var save_dictionary : Dictionary[String, Variant]
	
	var prop_list = save_data.get_script().get_script_property_list()
	
	print(prop_list)
	for prop_metadata in prop_list:
		if prop_metadata["type"] != Variant.Type.TYPE_NIL:
			#print(prop_metadata)
			var prop_name : String = prop_metadata["name"]
			var prop_value : Variant = save_data.get(prop_name)
			save_dictionary[prop_name] = prop_value

	var save_file = FileAccess.open("user://save" + str(save_number), FileAccess.WRITE)
	save_file.store_var(save_dictionary, false)
	save_file.close()
	
