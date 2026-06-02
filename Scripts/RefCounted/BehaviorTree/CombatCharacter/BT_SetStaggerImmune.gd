class_name BT_SetStaggerImmune extends BT_Node

var character_bb_key : String = "character"
var stagger_immune : bool = false

var _finished : bool = false

func tick(blackboard : Dictionary):
	if _finished == true:
		return SUCCESS
	
	var character : CombatCharacter = blackboard.get(character_bb_key)
	character.stagger_immune = stagger_immune
	print("stagger immune: " + str(stagger_immune))
	_finished = true
	
	return SUCCESS

func reset(_blackboard : Dictionary):
	_finished = false
