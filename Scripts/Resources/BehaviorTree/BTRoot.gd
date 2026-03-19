class_name BT_Root extends Node

@export var blackboard : Dictionary[String, Variant]
@export var child : BT_Composite

func _ready() -> void:
	for blackboard_key in blackboard:
		var blackboard_value = blackboard[blackboard_key]
		
		## Converts NodePaths to Nodes. 
		## Unfortunately a neccesary workaround for assigning node values for exported dictionaries.
		if blackboard_value is NodePath:
			blackboard[blackboard_key] = get_node(blackboard_value)

func _process(delta: float) -> void:
	blackboard.set("delta", delta)
	var result = child.tick(blackboard)
	if result == BT_Node.SUCCESS or result == BT_Node.FAILURE:
		print("Reseting Behavior Tree Root")
		child.reset(blackboard)
