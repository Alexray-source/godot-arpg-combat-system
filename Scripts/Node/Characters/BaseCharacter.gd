class_name BaseCharacter extends CharacterBody3D

enum ChrMovementType {
	GROUND,
	FLYING
}


#const GRAVITY_DIR : Vector3 = Vector3.DOWN

@export var move_speed : float = 7.0
@export var gravity_scale : float = 2.0
@export var state_machine : CharacterStateMachine
@export var chr_movement_type : ChrMovementType = ChrMovementType.GROUND

var move_dir : Vector3
#var up_velocity : Vector3
var move_velocity : Vector3 = Vector3.ZERO 
var prev_is_on_floor : bool = false

signal is_on_floor_changed(floored : bool)

func _ready() -> void:
	platform_floor_layers = 0
	state_machine.state_machine_setup()
	#state_machine.transition_to_state(state_machine.get_state_by_key("ground_movement"))
	on_floor_changed(is_on_floor())
	
	is_on_floor_changed.connect(on_floor_changed)

func on_floor_changed(_is_floored : bool) -> void:
	rescan_ground_state()

func rescan_ground_state():
	if state_machine.is_current_state_by_key("custom_movement"):
		return
	
	if chr_movement_type == ChrMovementType.FLYING:
		set_state("fly_movement")
	else:
		if is_on_floor():
			set_state("ground_movement")
		else:
			set_state("air_movement")

func calculate_gravity_force(up_velocity : Vector3, delta : float):
	var gravity_acceleration : Vector3 = get_gravity() * gravity_scale
	var gravity_velocity : Vector3 = (gravity_acceleration * delta)
	#up_velocity = (up_velocity + gravity_velocity).limit_length(20.0)
	up_velocity = (up_velocity + gravity_velocity)
	return up_velocity

func _physics_process(_delta: float) -> void:
	if is_on_floor() != prev_is_on_floor:
		is_on_floor_changed.emit(is_on_floor())
		
	prev_is_on_floor = is_on_floor()
	
	#if velocity.y > 15.0:
		#print("VERY HIGH VELOCITY")

func jump():
	if is_on_floor():
		#up_velocity = Vector3.ZERO
		velocity.y = 15.0
		move_and_slide()

func set_state(state_name : String):
	state_machine.transition_to_state_by_key(state_name)

func is_current_state(state_name : String) -> bool:
	return state_machine.is_current_state_by_key(state_name)
