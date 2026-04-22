class_name BT_GetClosestCharacter extends BT_Node

var origin_node_scan_key : String
var found_character_target_key : String
var scan_radius : float = 10.0
var scan_layer : int = 1
var scan_once : bool

var _found_character : bool
var _finished : bool
var _result := FAILURE

func tick(blackboard : Dictionary):
	if _finished == true:
		return _result
	
	if scan_once == true and _found_character == true:
		return SUCCESS
	
	var scan_shape : SphereShape3D = SphereShape3D.new()
	scan_shape.radius = scan_radius
	
	#print(blackboard.get(origin_node_scan_key))
	var origin : Node3D = blackboard.get(origin_node_scan_key) as Node3D
	
	var scanner = CombatCharacterScanner.new()
	var closest_character = scanner.get_closest_character_to_position(origin.global_position, origin.get_world_3d().direct_space_state, scan_shape, origin.transform.orthonormalized(), scan_layer)
	
	if closest_character != null:
		blackboard.set(found_character_target_key, closest_character)
		_found_character = true
		_result = SUCCESS
		return SUCCESS
	
	if scan_once == true:
		_finished = true
	
	_result = FAILURE
	return FAILURE

func reset(_blackboard : Dictionary):
	_found_character = false
	_finished = false
