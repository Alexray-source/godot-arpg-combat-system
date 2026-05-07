class_name BT_Root extends Node

@export var blackboard : Dictionary[String, Variant]
@export var tree_data : BT_CompositeData
@export var debug : bool = false
@export var active : bool = false

var child : BT_Composite

func create_tree_branch(composite : BT_CompositeData):
	var composite_node = composite.create_node()
	return composite_node

func _ready() -> void:
	for blackboard_key in blackboard:
		var blackboard_value = blackboard[blackboard_key]
		
		## Converts NodePaths to Nodes. 
		## Unfortunately a neccesary workaround for assigning node values for exported dictionaries.
		if blackboard_value is NodePath:
			blackboard[blackboard_key] = get_node(blackboard_value)
	
	##Construct Behavior Tree from Behavior Tree Data
	child = create_tree_branch(tree_data)

func get_running_child(_child : BT_Node):
	if _child is BT_Composite:
		return get_running_child(_child.running_child)
	
	return _child

func set_active(new_state : bool):
	active = new_state
	reset_behavior_tree()

func reset_behavior_tree():
	if debug == true:
			print("Reseting Behavior Tree Root")
			
	if child != null:
		child.reset(blackboard)

func _physics_process(delta: float) -> void:
	if active == false:
		return
	
	blackboard.set("delta", delta)
	var result = child.tick(blackboard)
	var running_node = get_running_child(child)
	
	if running_node != null and debug == true:
		print(running_node.get_script().get_global_name())
	
	if result == BT_Node.SUCCESS or result == BT_Node.FAILURE:
		reset_behavior_tree()
