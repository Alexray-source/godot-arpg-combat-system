class_name BT_SetCharacterMoveSpeed extends BT_Node

@export var character_bb_key : String
@export var new_move_speed : float = 50.0

var _finished : bool = false

func tick(blackboard : Dictionary):
	if _finished == true:
		return SUCCESS
	
	var character : BaseCharacter = blackboard_object_get(blackboard, character_bb_key)
	
	if character == null:
		return FAILURE
	
	character.move_speed = new_move_speed
	_finished = true
	return SUCCESS

func reset(_blackboard : Dictionary):
	_finished = false
