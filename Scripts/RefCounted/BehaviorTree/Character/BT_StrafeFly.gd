class_name BT_StrafeFly extends BT_Node

var character_bb_key : String
var target_bb_key : String
var strafe_height_relative_to_target : float = 5.0
var accumulated_time : float = 0.0
var max_strafe_time : float = 4.0

var _finished : bool = false
var _strafe_angle : float = 0.0

func tick(blackboard : Dictionary):
	if _finished == true:
		return SUCCESS
	
	var delta = blackboard.get("delta")
	accumulated_time += delta
	#print(accumulated_time)
	
	var character : BaseCharacter = blackboard_object_get(blackboard, character_bb_key)
	var target : Node3D = blackboard_object_get(blackboard, target_bb_key)
	
	if character == null or target == null:
		return FAILURE
	
	if accumulated_time > max_strafe_time:
		_finished = true
		character.move_dir = Vector3.ZERO
		return SUCCESS
	

	var move_dir : Vector3 = character.global_position.direction_to(target.global_position).rotated(Vector3.UP, _strafe_angle)
	
	var target_height : float = target.global_position.y + strafe_height_relative_to_target
	
	var height_move_dir : Vector3 = Vector3(0.0, target_height - character.global_position.y , 0.0)
	
	character.move_dir = Vector3(move_dir.x, height_move_dir.y, move_dir.z)
	
	return RUNNING

func reset(_blackboard : Dictionary):
	accumulated_time = 0.0
	_finished = false
	_strafe_angle = randf_range(PI*0.5, PI*1.5)
