class_name BT_CombatCharacterAbility extends BT_Node

var character_bb_key : String
var target_node_bb_key : String
var ability_name : String
var indicator_vfx : String

var _finished : bool = false


func tick(blackboard : Dictionary):
	if _finished == false:
		var base_chr : CombatCharacter = blackboard_object_get(blackboard, character_bb_key)
		var target_node : Node3D = blackboard_object_get(blackboard, target_node_bb_key)
		
		if base_chr == null:
			return FAILURE
		
		base_chr.lock_to_target(target_node)
		base_chr.perform_ability(ability_name)
		
		if indicator_vfx.is_empty() == false:
			GlobalSignals.spawn_vfx.emit(indicator_vfx, base_chr.global_transform.orthonormalized())
		
		_finished = true
	return SUCCESS

func reset(_blackboard : Dictionary):
	_finished = false
