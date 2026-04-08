class_name AbilityDatabase extends Resource

@export var database : Dictionary[String, AbilityDB_Entry]

func get_ability_db_entry(ability_key : String):
	return database[ability_key]
