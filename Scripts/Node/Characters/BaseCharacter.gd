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
	if is_floored == true:
		state_machine.transition_to_state(state_machine.get_state_by_key("ground_movement"))
	else:
		state_machine.transition_to_state(state_machine.get_state_by_key("air_movement"))

func _physics_process(delta: float) -> void:
	if is_on_floor() != prev_is_on_floor:
		is_on_floor_changed.emit(is_on_floor())
	
	#if move_dir.length() > 0.0:
		#move_velocity = move_dir.normalized() * move_speed * delta * 10.0
	#else:
		#move_velocity = Vector3.ZERO
	#
	#if is_on_floor():
		#up_velocity = Vector3(0.0,-0.1,0.0)
	#else:
		#up_velocity = velocity * -GRAVITY_DIR
		#var gravity_acceleration : Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity") * GRAVITY_DIR * gravity_scale
		#var gravity_velocity : Vector3 = (gravity_acceleration * delta).limit_length(20.0)
		#
		#up_velocity += gravity_velocity
#
	#var velocity_xz_plane : Vector3 = Vector3(velocity.x, 0.0, velocity.z)
	#
	#if velocity_xz_plane.length() > 0.0:
		#global_basis = Basis.looking_at(velocity_xz_plane, -GRAVITY_DIR)
	#
	#velocity = up_velocity + move_velocity
	prev_is_on_floor = is_on_floor()
	#move_and_slide()


func jump():
	if is_on_floor():
		up_velocity = Vector3.ZERO
		velocity.y = 15.0
		move_and_slide()

func set_state(state_name : String):
	state_machine.transition_to_state(state_machine.get_state_by_key(state_name))
