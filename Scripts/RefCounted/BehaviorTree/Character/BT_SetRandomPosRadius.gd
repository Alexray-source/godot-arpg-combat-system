class_name BT_SetRandomPosRadius extends BT_Node

var origin_node_bb_key : String = "character"
var target_pos_key : String
var horizontal_randomness : float = 5.0
var vertical_randomness : float = 0.0

var _finished : bool = false

func tick(blackboard : Dictionary):
	if _finished == true:
		return SUCCESS
	
	var origin_node : Node3D = blackboard_object_get(blackboard, origin_node_bb_key)
	
	if origin_node == null:
		return FAILURE
	
	blackboard[target_pos_key] = origin_node.global_position + Vector3(randf_range(-horizontal_randomness, horizontal_randomness), randf_range(-vertical_randomness, vertical_randomness), randf_range(-horizontal_randomness, horizontal_randomness))
	
	_finished = true
	return SUCCESS

func reset(blackboard : Dictionary):
	_finished = false
	blackboard[target_pos_key] = null
