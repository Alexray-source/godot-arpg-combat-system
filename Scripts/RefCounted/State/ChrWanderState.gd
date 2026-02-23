class_name ChrWanderState extends CharacterState

var time_passed : float = 0.0
var wander_dir : Vector3 = Vector3.FORWARD

func randomize_wander_dir():
	wander_dir = Vector3(sin(randf_range(-PI, PI)), 0.0, sin(randf_range(-PI,PI))).normalized()

func on_enter() -> void:
	randomize_wander_dir()

func on_exit() -> void:
	time_passed = 0.0

func state_physics_process(_delta : float) -> void:
	time_passed += _delta
	
	character.move_dir = wander_dir
	
	if time_passed > 4.0:
		time_passed = 0.0
		randomize_wander_dir()
