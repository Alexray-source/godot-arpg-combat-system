class_name SaveDataHandler extends RefCounted

func load_from_disk(save_number) -> SaveData:
	var new_save_data : SaveData = SaveData.new()
	new_save_data.data = {}
	
	var save_file = FileAccess.open("user://save" + str(save_number), FileAccess.READ)
	
	if save_file == null:
		print("No data loaded")
		return new_save_data
	
	var data = save_file.get_var(false)
	save_file.close()

	
	if data is not Dictionary:
		print("Invalid or corrupted save data, returning empty data")
		return new_save_data
	print(data)
	
	for data_key in data:
		new_save_data.data.set(data_key, data[data_key])
		
	return new_save_data

func save_to_disk(save_data : SaveData, save_number):
	var save_dictionary : Dictionary[String, Variant]
	
	#var prop_list = save_data.get_script().get_script_property_list()
	var data : Dictionary[String, Variant] = save_data.data
	#print(prop_list)
	for data_key in data:
			#print(prop_metadata)
			var data_value : Variant = data.get(data_key)
			save_dictionary[data_key] = data_value
			print(data_key + ":" + " " + str(data_value))

	var save_file = FileAccess.open("user://save" + str(save_number), FileAccess.WRITE)
	var result = save_file.store_var(save_dictionary, false)
	print(result)
	save_file.close()
	

func delete_from_disk(save_number):
	DirAccess.remove_absolute("user://save" + str(save_number))
