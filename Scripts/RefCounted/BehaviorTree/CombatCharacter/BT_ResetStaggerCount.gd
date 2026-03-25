class_name BT_ResetStaggerCount extends BT_Node

var character_bb_key : String = "character"

var _finished : bool = true

func tick(blackboard : Dictionary):
	if _finished == true:
		return SUCCESS
	
	var character : CombatCharacter = blackboard.get(character_bb_key) as CombatCharacter
	
	character.reset_stagger_count()
	
	_finished = true
	return SUCCESS

func reset(_blackboard : Dictionary):
	_finished = false
