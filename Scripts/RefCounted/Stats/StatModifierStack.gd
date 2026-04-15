class_name StatModifierStack extends RefCounted

var stat_modifiers : Dictionary[String, StatModifierData]

func _init(start_stack : Dictionary[String, StatModifierData] = {}) -> void:
	stat_modifiers = start_stack

func is_modifier_key_in_use(modifier_key : String):
	return stat_modifiers.get(modifier_key) != null

func add_modifier(modifier_key : String, stat_modifier : StatModifierData):
	stat_modifiers[modifier_key] = stat_modifier

func remove_modifier(modifier_key : String):
	stat_modifiers.erase(modifier_key)

func get_stat_stack_value(stat : StatModifierData.Stats):
	var stat_value : float = 0.0
	for modifier_key in stat_modifiers:
		var stat_modifier : StatModifierData = stat_modifiers[modifier_key]
		
		if stat_modifier.stat == stat:
			if stat_modifier.modify_mode == StatModifierData.ModifyMode.ADD:
				stat_value += stat_modifier.factor
			else:
				stat_value -= stat_modifier.factor
	
	return stat_value
