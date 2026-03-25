class_name BT_StaggerCounter extends BT_Node

var character_bb_key : String = "character"
var stagger_count_treshold : int = 3

var _threshold_reached : bool = false

func tick(blackboard : Dictionary):
	if _threshold_reached == true:
		return SUCCESS
	
	var character : CombatCharacter = blackboard.get(character_bb_key) as CombatCharacter
	
	if character._stagger_count > stagger_count_treshold:
		#print("Reached stagger threshold")
		print(character._stagger_count)
		_threshold_reached = true
		return SUCCESS
	else:
		return FAILURE

func reset(_blackboard : Dictionary):
	_threshold_reached = false
