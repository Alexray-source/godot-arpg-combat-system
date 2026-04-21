class_name TemporaryNode extends Node

@export var target_node : Node
@export var lifetime : float = 1.0

func _ready() -> void:
	get_tree().create_timer(lifetime).timeout.connect(target_node.queue_free)
