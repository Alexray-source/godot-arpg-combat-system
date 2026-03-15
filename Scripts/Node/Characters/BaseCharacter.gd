class_name BaseCharacter extends CharacterBody3D

const GRAVITY_DIR : Vector3 = Vector3.DOWN

@export var move_speed : float = 10.0
@export var gravity_scale : float = 2.0
@export var state_machine : CharacterStateMachine

var move_dir : Vector3
var up_velocity : Vector3
var move_velocity : Vector3 = Vector3.ZERO 
var prev_is_on_floor : bool = false

signal is_on_floor_changed(floored : bool)

func _ready() -> void:
	state_machine.state_machine_setup()
	#state_machine.transition_to_state(state_machine.get_state_by_key("ground_movement"))
	on_floor_changed(is_on_floor())
	
	is_on_floor_changed.connect(on_floor_changed)

func on_floor_changed(is_floored) -> void:
	rescan_ground_state()

func rescan_ground_state():
	if is_on_floor():
		set_state("ground_movement")
	else:
		set_state("air_movement")

func _physics_process(_delta: float) -> void:
	if is_on_floor() != prev_is_on_floor:
		is_on_floor_changed.emit(is_on_floor())
		
	prev_is_on_floor = is_on_floor()

func jump():
	if is_on_floor():
		up_velocity = Vector3.ZERO
		velocity.y = 15.0
		move_and_slide()

func set_state(state_name : String):
	state_machine.transition_to_state(state_machine.get_state_by_key(state_name))
