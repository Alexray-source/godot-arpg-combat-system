class_name BT_CharacterTeleportToPosition extends BT_Node

var character_bb_key : String
var target_position_bb_key : String
var randomnness_radius : float = 1.0

var _finished : bool = false

func tick(blackboard : Dictionary):
	if _finished == true:
		return SUCCESS
	
	var base_chr : BaseCharacter = blackboard.get(character_bb_key) as BaseCharacter
	var target_position : Vector3 = blackboard.get(target_position_bb_key) as Vector3
	
	base_chr.global_position = target_position + Vector3(randf_range(-randomnness_radius,randomnness_radius), 0.0, randf_range(-randomnness_radius,randomnness_radius))
	
	_finished = true
	
	return SUCCESS

func reset(_blackboard : Dictionary):
	_finished = false
