extends Node3D

@export var character : CombatCharacter
@export var plr_state_machine : PlrCharacterStateMachine
@export var camera_arm : ChrCamArm
@export var target_tracking_camera : TargetTrackingCamera

@export var camera_arm_center_rest_offset : Vector3 = Vector3(0.0,2.0,0.0)
@export var camera_max_v_angle : float = PI * 0.2
@export var camera_min_v_angle : float = -PI * 0.2
@export var targeting_cancel_distance_treshold : float = 40.0

var camera_rot_x : float = 0.0
var camera_rot_y : float = 0.0
var camera_rot_x_accel : float = 0.0
var camera_rot_y_accel : float = 0.0

var camera_sens_x : float = 2.0
var camera_sens_y : float = 0.9
var camera_center_offset : Vector3

var current_target : Node3D

var input_events : PlrInputEvents

var plr_debounces : Debounces

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	input_events = PlrInputEvents.new()
	plr_debounces = Debounces.new()
	
	plr_state_machine.input_events = input_events
	plr_state_machine.state_machine_setup()
	plr_state_machine.transition_to_state(plr_state_machine.get_state_by_key("movement"))
	
	character.character_abilities.ability_finished.connect(return_to_movement_state)
	
	character.dash_component.dash_ended.connect(return_to_movement_state)
	
	input_events.primary_atk_input.connect(on_primary_atk)
	input_events.secondary_atk_input.connect(on_secondary_atk)
	input_events.special_atk1_input.connect(on_special_atk.bind(1))
	input_events.special_atk2_input.connect(on_special_atk.bind(2))
	input_events.special_atk3_input.connect(on_special_atk.bind(3))
	
	input_events.grapple_object_input.connect(on_grapple.bind(false))
	input_events.grapple_enemy_input.connect(on_grapple.bind(true))
	
	input_events.target_lock.connect(on_toggle_target_lock)
	input_events.target_next.connect(on_target_next)

	input_events.dash_input.connect(on_dodge_dash)


func get_special_atk_debounce_string(atk_index : int):
	return "attack" + str(atk_index)

func return_to_movement_state():
	plr_state_machine.transition_to_state(plr_state_machine.get_state_by_key("movement"))

func on_primary_atk() -> void:
	#print(character.debounces.is_debounce_active("attack"))
	if character is CombatCharacter and character.debounces.is_debounce_active("attack") == false:
		plr_state_machine.transition_to_state_by_key("primary_atk")

func on_secondary_atk() -> void:
	character.perform_ability("secondary_atk")

func on_special_atk(atk_index : int) -> void:
	var debounce_string = get_special_atk_debounce_string(atk_index)
	
	if character is CombatCharacter and plr_debounces.is_debounce_active(debounce_string) == false and character.debounces.is_debounce_active("attack") == false:
		plr_debounces.add_debounce(debounce_string)
		plr_debounces.remove_debounce_delayed(debounce_string, 1.0)
		
		plr_state_machine.transition_to_state_by_key("special_atk" + str(atk_index))

func on_grapple(targets_characters : bool) -> void:
	if character is CombatCharacter and character.debounces.is_debounce_active("attack") == false:
		#character.grapple()
		if targets_characters == true:
			character.perform_ability("grapple_enemy")
		else:
			character.perform_ability("grapple_object")

func on_dodge_dash() -> void:
	if plr_debounces.is_debounce_active("dodge_dash") == false and character.state_machine.current_state != character.state_machine.get_state_by_key("stagger"): 
		plr_debounces.add_debounce("dodge_dash")
		plr_debounces.remove_debounce_delayed("dodge_dash", 1.0)
		plr_state_machine.transition_to_state_by_key("dodge_dash")

func on_toggle_target_lock() -> void:
	if current_target != null:
		#current_target = null
		set_lock_target(null)
	elif target_tracking_camera.targets_in_view.size() > 0:
		#current_target = target_tracking_camera.targets_in_view.get(0)
		set_lock_target(target_tracking_camera.targets_in_view.get(0))

func on_target_next() -> void:
	var current_index : int = 0
	
	if current_target != null:
		current_index = target_tracking_camera.targets_in_view.find(current_target)
		
		current_index += 1
		
		if current_index >= target_tracking_camera.targets_in_view.size():
			current_index = 0
	
	#current_target = target_tracking_camera.targets_in_view.get(current_index)
	set_lock_target(target_tracking_camera.targets_in_view.get(current_index))

func set_lock_target(new_target : Node3D) -> void:
	current_target = new_target
	character.lock_to_target(new_target)

func _input(event: InputEvent) -> void:
	input_events.input_pressed(event)

func handle_camera_rot(delta):
	var chr_movement_camera_influence : float = 0.0
	
	var current_cam = get_viewport().get_camera_3d()
	chr_movement_camera_influence = (current_cam.global_basis.x).dot(character.velocity.normalized()) * character.velocity.length() * 0.35
	
	var camera_move_dir : Vector2 = Vector2(-input_events.camera_move_dir.x - chr_movement_camera_influence, -input_events.camera_move_dir.y,)
	
	if current_target != null:
		#camera_move_dir = Vector2.ZERO
		var viewport_size : Vector2 = get_viewport().get_visible_rect().size
		var viewport_center_pos : Vector2 = viewport_size * 0.5
		
		var target_screen_pos : Vector2 = target_tracking_camera.unproject_position(current_target.global_position)
		
		var x_correction = -((target_screen_pos - viewport_center_pos).x / viewport_size.x)
		#print(x_correction)
		if abs(x_correction) > 0.1:
			camera_move_dir.x = (x_correction / viewport_size.x) * 25000.0
		
	
	camera_rot_y_accel = lerp(camera_rot_y_accel, camera_move_dir.x, delta * 10.0)
	camera_rot_x_accel = lerp(camera_rot_x_accel, camera_move_dir.y, delta * 10.0)
	
	camera_rot_y = wrapf(camera_rot_y + (camera_rot_y_accel * delta * 0.25 * camera_sens_y), 0.0, PI*2.0)
	camera_rot_x = clamp(camera_rot_x + (camera_rot_x_accel * delta * 0.25 * camera_sens_x), camera_min_v_angle, camera_max_v_angle)
	
	var new_cam_basis_horizontal = Basis(Vector3.UP, camera_rot_y)
	var new_cam_basis_vertical = Basis(Vector3.RIGHT, camera_rot_x)
	var new_cam_basis = new_cam_basis_horizontal * new_cam_basis_vertical.orthonormalized()
	
	camera_arm.global_basis = new_cam_basis
	
	if input_events.input_mode == PlrInputEvents.InputMode.KEYBOARD:
		input_events.camera_move_dir = Vector2(0.0,0.0)

func _process(delta: float) -> void:
	handle_camera_rot(delta)
	camera_center_offset = camera_arm_center_rest_offset
	
	if current_target != null:
		var target_to_camera_dir : Vector3 = (current_target.global_position - target_tracking_camera.global_position).normalized()
		target_to_camera_dir = Vector3(target_to_camera_dir.x, 0.0, target_to_camera_dir.z)
		
		var target_to_chr_distance = current_target.global_position.distance_to(character.global_position)
		
		camera_center_offset = camera_arm_center_rest_offset + ((current_target.global_position - character.global_position) * 0.75) + (target_to_camera_dir * -target_to_chr_distance)
		
		if current_target.global_position.distance_to(character.global_position) > targeting_cancel_distance_treshold:
			#current_target = null
			set_lock_target(null)
	
	camera_arm.target_offset_pos = lerp(camera_arm.target_offset_pos, camera_center_offset, delta * 5.0)
