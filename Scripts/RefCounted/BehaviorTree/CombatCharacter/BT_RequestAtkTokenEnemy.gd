class_name BT_RequestAtkTokenEnemy extends BT_Node

var chr_bb_key : String
var enemy_chr_bb_key : String
var token_lifetime : float = 2.0
var finished : bool = false
var succes_result

func tick(blackboard : Dictionary):
	if finished == true:
		return succes_result
	
	var chr : CombatCharacter = blackboard.get(chr_bb_key)
	var enemy_chr : CombatCharacter = blackboard.get(enemy_chr_bb_key)
	
	var request_result = enemy_chr.request_attack_token(chr, token_lifetime)
	#print(chr)
	#print(request_result)
	if request_result == true:
		succes_result = SUCCESS
	else:
		succes_result = FAILURE
	
	finished = true
	return succes_result
	

func reset(_blackboard : Dictionary):
	finished = false
