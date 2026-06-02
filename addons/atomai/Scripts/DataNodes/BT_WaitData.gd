@tool
class_name BT_WaitData extends BT_NodeData

@export var interval : float = 1.0
@export var randomness : float = 0.0
@export var debug : bool = false

func _init() -> void:
	resource_name = "Wait"

func create_node() -> BT_Node:
	var node = BT_Wait.new()
	node.interval = interval
	node.randomness = randomness
	node.debug = debug
	node.reset({})
	
	return node
