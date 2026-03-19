class_name BT_CombatCharacterAbility extends BT_Node

@export var chr_bb_key : String
@export var target_node_bb_key : String
@export var ability_name : String

var _finished : bool = false


func tick(blackboard : Dictionary):
	if _finished == false:
		var base_chr : CombatCharacter = blackboard.get(chr_bb_key) as CombatCharacter
		var target_node : Node3D = blackboard.get(target_node_bb_key) as Node3D
		base_chr.lock_to_target(target_node)

		base_chr.perform_ability(ability_name)
		_finished = true
	return SUCCESS

func reset(blackboard : Dictionary):
	_finished = false
