class_name BT_GetClosestCharacter extends BT_Node

var origin_node_scan_key : String
var found_character_target_key : String
var scan_radius : float = 10.0
var scan_layer : int = 1

func tick(blackboard : Dictionary):
	var scan_shape : SphereShape3D = SphereShape3D.new()
	scan_shape.radius = scan_radius
	
	#print(blackboard.get(origin_node_scan_key))
	var origin : Node3D = blackboard.get(origin_node_scan_key) as Node3D
	
	var scanner = CombatCharacterScanner.new()
	var closest_character = scanner.get_closest_character_to_position(origin.global_position, origin.get_world_3d().direct_space_state, scan_shape, origin.transform.orthonormalized(), scan_layer)
	
	if closest_character != null:
		blackboard.set(found_character_target_key, closest_character)
		return SUCCESS
	
	return FAILURE
