@abstract class_name BT_Node extends Resource

enum {
	SUCCESS,
	FAILURE,
	RUNNING
}

@abstract func tick(blackboard : Dictionary)

func reset(blackboard : Dictionary):
	pass
