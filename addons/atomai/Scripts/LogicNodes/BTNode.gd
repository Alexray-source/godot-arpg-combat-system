@abstract class_name BT_Node extends RefCounted

enum {
	SUCCESS,
	FAILURE,
	RUNNING
}

@abstract func tick(blackboard : Dictionary)

func blackboard_object_get(blackboard : Dictionary, bb_key : String):
	if is_instance_valid(blackboard.get(bb_key)):
		return blackboard.get(bb_key)
	else:
		return null

func reset(_blackboard : Dictionary):
	pass
