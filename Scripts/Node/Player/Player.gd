extends Node3D

const ABILITY_DB : AbilityDatabase = preload("res://Resources/AbilityDatabase.tres")

@export var character_data : CharacterData
@export var character : CombatCharacter
@export var plr_state_machine : PlrCharacterStateMachine
@export var camera_arm : ChrCamArm
@export var target_tracking_camera : TargetTrackingCamera
@export var hud : PlayerHUD

@export var camera_arm_center_rest_offset : Vector3 = Vector3(0.0,2.0,0.0)
@export var camera_max_v_angle : float = PI * 0.2
@export var camera_min_v_angle : float = -PI * 0.2
@export var targeting_cancel_distance_treshold : float = 40.0
@export var max_ability_energy : int = 100

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
var ability_energy : int = 0:
	set(_value):
		ability_energy = _value
		ability_energy_changed.emit()

var equipped_abilities_keys : Array[String]
var plr_special_atk_state : PlrSpecialAtkState

signal ability_energy_changed()


func _ready() -> void:
	character = character_data.character_scene.instantiate()
	add_child(character)
	camera_arm.target = character
	plr_state_machine.character = character
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	input_events = PlrInputEvents.new()
	input_events.setup()
	
	plr_debounces = Debounces.new()
	
	plr_state_machine.input_events = input_events
	plr_state_machine.state_machine_setup()
	plr_state_machine.transition_to_state(plr_state_machine.get_state_by_key("movement"))
	plr_special_atk_state = plr_state_machine.get_state_by_key("special_atk")
	
	equipped_abilities_keys.resize(character_data.available_abilities.size())
	
	var ability_index: int = 0
	for ability_key in character_data.available_abilities:
		var ability_db_entry : AbilityDB_Entry = ABILITY_DB.get_ability_db_entry(ability_key)
		
		character.character_abilities.add_ability_data(ability_key, ability_db_entry.ability_data)
		character.character_abilities.create_and_store_ability_component(ability_key)
		
		equipped_abilities_keys[ability_index] = ability_key
		ability_index += 1
	
	character.ability_finished.connect(return_to_movement_state)
	
	character.enemies_hit.connect(on_enemies_hit)
	character.dash_component.dash_ended.connect(return_to_movement_state)
	
	ability_energy_changed.connect(on_ability_energy_changed)
	
	input_events.primary_atk_input.connect(on_primary_atk)
	input_events.secondary_atk_input.connect(on_secondary_atk)
	input_events.special_atk1_input.connect(on_special_atk.bind(0))
	input_events.special_atk2_input.connect(on_special_atk.bind(1))
	input_events.special_atk3_input.connect(on_special_atk.bind(2))
	
	input_events.grapple_object_input.connect(on_grapple.bind(false))
	input_events.grapple_enemy_input.connect(on_grapple.bind(true))
	
	input_events.target_lock.connect(on_toggle_target_lock)
	input_events.target_next.connect(on_target_next)

	input_events.dash_input.connect(on_dodge_dash)

func on_ability_energy_changed():
	hud.ability_energy_bar.value = ability_energy / float(max_ability_energy)
	
	for ability_key in equipped_abilities_keys:
		var ability_index = equipped_abilities_keys.find(ability_key)
		var ability_entry : AbilityDB_Entry = ABILITY_DB.get_ability_db_entry(ability_key)
		var ability_fill_factor : float = (ability_energy / float(ability_entry.ability_energy_cost))
		
		hud.update_ability_icon_fill(ability_index, ability_fill_factor)

func on_enemies_hit(enemy_hurtboxes : Array[HurtBox]):
	ability_energy = clampi(ability_energy + (10.0 * enemy_hurtboxes.size()), 0, max_ability_energy)

func deplete_ability_energy(amount : int):
	ability_energy = clampi(ability_energy - amount, 0, max_ability_energy)

func get_special_atk_debounce_string(atk_index : int):
	return "attack" + str(atk_index)

func return_to_movement_state():
	plr_state_machine.transition_to_state(plr_state_machine.get_state_by_key("movement"))

func on_primary_atk() -> void:
	#print(character.debounces.is_debounce_active("attack"))
	if character.debounces.is_debounce_active("attack") == false:
		plr_state_machine.transition_to_state_by_key("primary_atk")

func on_secondary_atk() -> void:
	if character.debounces.is_debounce_active("attack") == false:
		character.debounces.add_debounce("attack")
		character.perform_ability("secondary_atk")

func on_special_atk(atk_index : int) -> void:
	var ability_key = equipped_abilities_keys[atk_index]
	if ability_key == null:
		return
	
	var debounce_string = get_special_atk_debounce_string(atk_index)
	var ability_db_entry : AbilityDB_Entry = ABILITY_DB.get_ability_db_entry(ability_key)
	
	if character is CombatCharacter and plr_debounces.is_debounce_active(debounce_string) == false and character.debounces.is_debounce_active("attack") == false and ability_energy >= ability_db_entry.ability_energy_cost:
		character.debounces.add_debounce("attack")
		deplete_ability_energy(ability_db_entry.ability_energy_cost)
		plr_debounces.add_debounce(debounce_string)
		plr_debounces.remove_debounce_delayed(debounce_string, 1.0)
		
		plr_special_atk_state.ability_key = ability_key
		
		plr_state_machine.transition_to_state(plr_special_atk_state)

func on_grapple(targets_characters : bool) -> void:
	if character is CombatCharacter and character.debounces.is_debounce_active("attack") == false and plr_debounces.is_debounce_active("grapple") == false:
		#character.grapple()
		plr_debounces.add_debounce("grapple")
		plr_debounces.remove_debounce_delayed("grapple", 0.5)
		
		if targets_characters == true:
			character.perform_ability("grapple_enemy")
		else:
			character.perform_ability("grapple_object")
		

func on_dodge_dash() -> void:
	if character.debounces.is_debounce_active("attack") == false and plr_debounces.is_debounce_active("dodge_dash") == false and character.state_machine.current_state != character.state_machine.get_state_by_key("stagger") and character.state_machine.current_state != character.state_machine.get_state_by_key("knockback"): 
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
	if current_target != null and current_target.tree_exiting.is_connected(handle_target_tree_exit) == true:
		current_target.tree_exiting.disconnect(handle_target_tree_exit)
	
	current_target = new_target
	character.lock_to_target(new_target)
	
	if current_target != null and current_target.tree_exiting.is_connected(handle_target_tree_exit) == false:
		current_target.tree_exiting.connect(handle_target_tree_exit.bind(current_target))

func handle_target_tree_exit(_exiting_target : Node3D) -> void:
	if current_target == _exiting_target:
		#on_target_next()
		set_lock_target(null)

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
		if target_tracking_camera.is_position_behind(current_target.global_position):
			var camera_look_dir : Vector3 = -target_tracking_camera.global_basis.z
			camera_move_dir.x = camera_look_dir.signed_angle_to(target_tracking_camera.global_position.direction_to(current_target.global_position), target_tracking_camera.global_basis.y) * 10.0
		elif abs(x_correction) > 0.1:
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
		
		var target_to_chr_distance = current_target.global_position.distance_to(character.global_position) * 0.9
		
		camera_center_offset = camera_arm_center_rest_offset + ((current_target.global_position - character.global_position) * 0.8) + (target_to_camera_dir * -target_to_chr_distance)
		
		if current_target.global_position.distance_to(character.global_position) > targeting_cancel_distance_treshold:
			#current_target = null
			set_lock_target(null)
	
	camera_arm.target_offset_pos = lerp(camera_arm.target_offset_pos, camera_center_offset, delta * 5.0)
