class_name BT_ForceResult extends BT_Node

enum ForcedResult {
	SUCCESS,
	FAILURE,
	RUNNING
}

var forced_result : ForcedResult = ForcedResult.SUCCESS

func tick(blackboard : Dictionary):
	return forced_result
