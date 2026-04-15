@abstract class_name StatModifierInterruptData extends Resource

@abstract func create_interrupt(node_owner : Node) -> StatModifierInterrupt

func get_node_from_nodepath(node_origin : Node, node_path : String) -> Node:
	return node_origin.get_node(node_path)
