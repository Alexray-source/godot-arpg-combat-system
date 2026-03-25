@abstract class_name BT_Node extends RefCounted

enum {
	SUCCESS,
	FAILURE,
	RUNNING
}

@abstract func tick(blackboard : Dictionary)

func reset(_blackboard : Dictionary):
	pass
