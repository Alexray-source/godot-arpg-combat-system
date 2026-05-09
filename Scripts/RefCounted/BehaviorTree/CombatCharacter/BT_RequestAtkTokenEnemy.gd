class_name BT_RequestAtkTokenEnemy extends BT_Node

var chr_bb_key : String
var enemy_chr_bb_key : String
var token_lifetime : float = 2.0
var finished : bool = false
var chr_must_be_in_camera : bool = true
var succes_result

func tick(blackboard : Dictionary):
	if finished == true:
		return succes_result
	
	var chr : BaseCharacter = blackboard_object_get(blackboard, chr_bb_key)
	var enemy_chr : Node3D = blackboard_object_get(blackboard, enemy_chr_bb_key)
	
	if chr == null or enemy_chr == null:
		finished = true
		succes_result = FAILURE
		return FAILURE
	
	if chr_must_be_in_camera == true:
		var active_camera : Camera3D = chr.get_viewport().get_camera_3d()
		var is_in_camera : bool = active_camera.is_position_in_frustum(chr.global_position) 
	
		if is_in_camera == false:
			finished = true
			succes_result = FAILURE
			return FAILURE
	
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
