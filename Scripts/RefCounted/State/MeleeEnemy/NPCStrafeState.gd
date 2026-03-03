class_name NPCAgroStrafeState extends EnemyNPCState

#var time_passed : float = 0.0
var wander_dir : Vector3 = Vector3.FORWARD
var scan_shape = SphereShape3D.new()
var scan_radius = 40.0
var attack_radius = 5.0

#func randomize_wander_dir():
	#wander_dir = Vector3(sin(randf_range(-PI, PI)), 0.0, sin(randf_range(-PI,PI))).normalized()

func on_enter() -> void:
	scan_shape.radius = scan_radius
	character.move_speed = 8.0
	#randomize_wander_dir()

#func on_exit() -> void:
	#time_passed = 0.0

func state_physics_process(_delta : float) -> void:
	#time_passed += _delta
	wander_dir = character.global_basis.x
	target = get_closest_combat_enemy(scan_radius)
	#print(target)
	if target != null:
		wander_dir = (character.global_position - target.global_position).rotated(Vector3.UP, PI*0.5)
		
		if ((character.global_position - target.global_position).length() < attack_radius):
			state_end.emit()
	else:
		state_end.emit()
	
	character.move_dir = wander_dir
	

	
	#if time_passed > 4.0:
		#time_passed = 0.0
		#randomize_wander_dir()
