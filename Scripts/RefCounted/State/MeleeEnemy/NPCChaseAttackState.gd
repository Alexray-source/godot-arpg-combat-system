class_name NPCChaseState extends EnemyNPCState

#var time_passed : float = 0.0
var wander_dir : Vector3 = Vector3.FORWARD
var scan_shape = SphereShape3D.new()
var scan_radius = 35.0
var attack_radius = 2.0

func on_enter() -> void:
	scan_shape.radius = scan_radius
	character.move_speed = 45.0

#func on_exit() -> void:
	#state_end.emit()

func state_physics_process(_delta : float) -> void:
	if character.state_machine.get_state_by_key("knockback") == character.state_machine.current_state:
		return
	
	target = get_closest_combat_enemy(scan_radius)
	
	if target != null:
		wander_dir = (target.global_position - character.global_position).normalized()
		
		if ((character.global_position - target.global_position).length() < attack_radius):
			state_end.emit()
	else:
		state_end.emit()
	
	character.move_dir = wander_dir
