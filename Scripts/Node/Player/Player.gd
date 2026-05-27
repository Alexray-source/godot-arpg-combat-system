extends Node3D

const ABILITY_DB : AbilityDatabase = preload("res://Resources/AbilityDatabase.tres")
const GAME_OVER_UI_SCENE : PackedScene = preload("res://Scenes/UI/GameOver.tscn")
const TARGET_RETICLE_SCENE : PackedScene = preload("res://Scenes/UI/target_reticle.tscn")
const INACTIVE_TARGET_RETICLE_SCENE : PackedScene = preload("res://Scenes/UI/inactive_target_reticle.tscn")


const TITLE_SCREEN_PATH : String = "res://Scenes/UI/title.tscn"

@export var character_data : CharacterData
@export var character : CombatCharacter
#@export var plr_state_machine : PlrCharacterStateMachine
@export var camera_arm : ChrCamArm
@export var target_tracking_camera : TargetTrackingCamera
@export var hud : PlayerHUD
@export var enemy_indicators : NearbyEnemyIndicatorsUI

@export var camera_arm_center_rest_offset : Vector3 = Vector3(0.0,2.0,0.0)
@export var camera_max_v_angle : float = PI * 0.2
@export var camera_min_v_angle : float = -PI * 0.2
@export var targeting_cancel_distance_treshold : float = 40.0
@export var max_ability_energy : int = 100

@export_subgroup("Camera Settings")
@export var block_shake : ShakeInfo
@export var hit_shake : ShakeInfo

var current_camera : Camera3D
var camera_rot_x : float = -0.35
var camera_rot_y : float = 0.0
var camera_rot_x_accel : float = 0.0
var camera_rot_y_accel : float = 0.0

var camera_sens_x : float = 2.0
var camera_sens_y : float = 0.9
var camera_center_offset : Vector3

var current_target : Node3D
var target_reticle : Node3D
var inactive_target_reticle : Node3D

var input_events : PlrInputEvents
var block_input : bool = false
var allow_parry : bool = false

var plr_debounces : Debounces
var ability_energy : int = 0:
	set(_value):
		ability_energy = _value
		ability_energy_changed.emit()

var equipped_abilities_keys : Array[String]
#var plr_special_atk_state : PlrSpecialAtkState
var attacking_enemies : Array[Enemy]

var _block_stamina : float = 100.0
var _block_combo : int = 0
var _plr_camera : Camera3D
var _closest_target : Node3D

signal ability_energy_changed()
signal block_stamina_empty()

func _ready() -> void:
	GlobalSignals.camera_changed.connect(set_active_camera)
	GlobalSignals.plr_input_state_changed.connect(set_input_state)
	
	set_active_camera(get_viewport().get_camera_3d())
	_plr_camera = target_tracking_camera.camera
	
	character = character_data.character_scene.instantiate()
	add_child(character)
	character.add_to_group("player_chr")
	enemy_indicators.track_origin = character
	camera_arm.target = character
	#plr_state_machine.character = character
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	input_events = PlrInputEvents.new()
	input_events.setup()
	
	plr_debounces = Debounces.new()
	
	hud._max_stamina = _block_stamina
	
	equipped_abilities_keys.resize(character_data.available_abilities.size())
	
	for i in range(4):
		hud.set_ability_icon(i, null)
	
	var ability_index: int = 0
	for ability_key in character_data.available_abilities:
		var ability_db_entry : AbilityDB_Entry = ABILITY_DB.get_ability_db_entry(ability_key)
		
		character.character_abilities.add_ability_data(ability_key, ability_db_entry.ability_data)
		character.character_abilities.create_and_store_ability_component(ability_key)
		
		hud.set_ability_icon(ability_index, ability_db_entry.ability_icon)
		
		equipped_abilities_keys[ability_index] = ability_key
		ability_index += 1
	
	#character.ability_finished.connect(return_to_movement_state)
	
	character.enemies_hit.connect(on_enemies_hit)
	#character.dash_component.dash_ended.connect(return_to_movement_state)
	
	hud.update_health_bar(character.health_component.health, character.health_component.max_health)

	character.damage_hit.connect(on_damage_hit)
	character.chr_died.connect(on_died, CONNECT_ONE_SHOT)
	character.atk_blocked.connect(on_atk_blocked)
	
	on_ability_energy_changed()
	ability_energy_changed.connect(on_ability_energy_changed)
	#block_stamina_empty.connect(on_block_energy_empty)
	
	input_events.primary_atk_input.connect(on_primary_atk)
	input_events.secondary_atk_input.connect(on_secondary_atk)
	input_events.special_atk1_input.connect(on_special_atk.bind(0))
	input_events.special_atk2_input.connect(on_special_atk.bind(1))
	input_events.special_atk3_input.connect(on_special_atk.bind(2))
	input_events.special_atk4_input.connect(on_special_atk.bind(3))
	
	input_events.grapple_input.connect(on_grapple)
	#input_events.grapple_enemy_input.connect(on_grapple.bind(true))
	#input_events.switch_grapple_mode.connect(func():
		#_grapple_enemies = not _grapple_enemies
		#hud.update_grapple_mode(_grapple_enemies)
		#print(_grapple_enemies)
	#)
	
	input_events.target_lock.connect(on_toggle_target_lock)
	input_events.target_next.connect(on_target_next)
	input_events.target_prev.connect(on_target_prev)
	
	input_events.jump_input.connect(character.jump)
	input_events.dash_input.connect(on_dodge_dash)
	input_events.sprint_start.connect(character.set_sprint.bind(true))
	input_events.sprint_end.connect(character.set_sprint.bind(false))
	
	input_events.block_start.connect(on_block_start)
	input_events.block_end.connect(on_block_end)
	
	target_reticle = TARGET_RETICLE_SCENE.instantiate()
	target_reticle.top_level = true
	add_child(target_reticle)
	target_reticle.visible = false
	
	inactive_target_reticle = INACTIVE_TARGET_RETICLE_SCENE.instantiate()
	inactive_target_reticle.top_level = true
	add_child(inactive_target_reticle)
	inactive_target_reticle.visible = false
	
	target_tracking_camera.closest_target_changed.connect(on_closest_target_changed)
	
	GlobalSignals.plr_chr_changed.emit(character)

func set_active_camera(new_camera : Camera3D):
	current_camera = new_camera

func on_ability_energy_changed():
	for ability_key in equipped_abilities_keys:
		var ability_index = equipped_abilities_keys.find(ability_key)
		var ability_entry : AbilityDB_Entry = ABILITY_DB.get_ability_db_entry(ability_key)
		var ability_fill_factor : float = (ability_energy / float(ability_entry.ability_energy_cost))
		
		hud.update_ability_icon_fill(ability_index, ability_fill_factor)

func on_enemies_hit(enemy_hurtboxes : Array[HurtBox]):
	GlobalSignals.shake_all_cameras.emit(hit_shake)
	ability_energy = clampi(ability_energy + (7.0 * enemy_hurtboxes.size()), 0, max_ability_energy)
	
	if current_target == null:
		var first_hurtbox = enemy_hurtboxes.get(0)
		
		if first_hurtbox == null or (first_hurtbox != null and first_hurtbox.is_in_group("targetable") == false):
			return
		
		set_lock_target(first_hurtbox)

func deplete_ability_energy(amount : int):
	ability_energy = clampi(ability_energy - amount, 0, max_ability_energy)

func get_special_atk_debounce_string(atk_index : int):
	return "attack" + str(atk_index)

#func return_to_movement_state():
	#plr_state_machine._transition_to_state(plr_state_machine.get_state_by_key("movement"))

func on_primary_atk() -> void:
	if character.state_machine.is_current_state_by_key("no_movement"):
		return
	
	#print(character.debounces.is_debounce_active("attack"))
	if character.debounces.is_debounce_active("attack") == false:
		#plr_state_machine.transition_to_state_by_key("primary_atk")
		character.primary_attack()

func on_secondary_atk() -> void:
	if character.state_machine.is_current_state_by_key("no_movement"):
		return
	
	if character.debounces.is_debounce_active("attack") == false:
		character.debounces.add_debounce("attack")
		character.perform_ability("secondary_atk")

func on_special_atk(atk_index : int) -> void:
	if character.state_machine.is_current_state_by_key("no_movement"):
		return
	
	var ability_key = equipped_abilities_keys.get(atk_index)
	if ability_key == null:
		return
	
	var debounce_string = get_special_atk_debounce_string(atk_index)
	var ability_db_entry : AbilityDB_Entry = ABILITY_DB.get_ability_db_entry(ability_key)
	
	if character is CombatCharacter and plr_debounces.is_debounce_active(debounce_string) == false and character.debounces.is_debounce_active("attack") == false and ability_energy >= ability_db_entry.ability_energy_cost:
		character.debounces.add_debounce("attack")
		hud.abilities_ui.activate_abililty(atk_index)
		deplete_ability_energy(ability_db_entry.ability_energy_cost)
		plr_debounces.add_debounce(debounce_string)
		plr_debounces.remove_debounce_delayed(debounce_string, 0.5)
		
		character.perform_ability(ability_key)
	elif ability_energy < ability_db_entry.ability_energy_cost:
		hud.abilities_ui.insufficient_energy_notification(atk_index)
	
func on_grapple() -> void:
	if character is CombatCharacter and plr_debounces.is_debounce_active("grapple") == false:
		#character.grapple()
		plr_debounces.add_debounce("grapple")
		plr_debounces.remove_debounce_delayed("grapple", 0.5)
		
		character.perform_ability("grapple")
		
		#if _grapple_enemies == true:
			#character.perform_ability("grapple_enemy")
		#else:
			#character.perform_ability("grapple_object")
		
func on_dodge_dash() -> void:
	var abs_move_dir : Vector3 = input_events.move_dir.abs()
	if abs_move_dir.x < 0.1 and abs_move_dir.z < 0.1:
		return

	if plr_debounces.is_debounce_active("dodge_dash") == false and character.is_current_state("knockback") == false: 
		plr_debounces.add_debounce("dodge_dash")
		plr_debounces.remove_debounce_delayed("dodge_dash", 0.5)
		
		character.dodge_dash()

func on_block_start() -> void:
	if character != null and _block_stamina >= 25.0:
		character.block()

func on_block_end() -> void:
	print("block release")
	if character != null and character.is_current_state("block"):
		character.rescan_ground_state()

func on_atk_blocked() -> void:
	_block_stamina = clampf(_block_stamina - 25.0, 0.0, 100.0)
	_block_combo += 1
	
	GlobalSignals.shake_all_cameras.emit(block_shake)
	
	if _block_combo >= 3:
		Engine.time_scale = 0.1
		_block_combo = 0
		allow_parry = true
		get_tree().create_timer(0.5, false, false, true).timeout.connect(func():
			Engine.time_scale = 1.0
			allow_parry = false
		)
	
	if _block_stamina <= 0.0:
		on_block_end()

func on_block_energy_empty() -> void:
	on_block_end()

func on_damage_hit(_atk_info : AtkInfo) -> void:
	hud.update_health_bar(character.health_component.health, character.health_component.max_health)

func on_died() -> void:
	block_input = true
	input_events.block_all_input = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	var game_over_ui : GameOverUI = GAME_OVER_UI_SCENE.instantiate()
	game_over_ui.retry.connect(GlobalSignals.restart_scene.emit, CONNECT_ONE_SHOT)
	game_over_ui.quit.connect(GlobalSignals.change_scene.emit.bind(TITLE_SCREEN_PATH), CONNECT_ONE_SHOT)
	
	add_child(game_over_ui)

func on_closest_target_changed(new_target : Node3D) -> void:
	_closest_target = new_target
	
	#if current_target == null:
		#inactive_target_reticle.visible = true

func on_toggle_target_lock() -> void:
	if plr_debounces.is_debounce_active("target_lock"):
		return
		
	plr_debounces.add_debounce("target_lock")
	plr_debounces.remove_debounce_delayed("target_lock", 0.5)
	
	if current_target != null:
		set_lock_target(null)
	elif target_tracking_camera.nearby_targets.size() > 0:
		set_lock_target(target_tracking_camera.nearby_targets.get(0))

func on_target_next(bypass_debounce : bool = false) -> void:
	if current_target == null:
		return
	
	print("searching new target")
	if bypass_debounce == false and plr_debounces.is_debounce_active("target_next"):
		return
	
	plr_debounces.add_debounce("target_next")
	plr_debounces.remove_debounce_delayed("target_next", 0.4)
	
	if target_tracking_camera.nearby_targets.size() > 0:
		
		var current_index : int = 0
		current_index = target_tracking_camera.nearby_targets.find(current_target)
		
		current_index += 1
		
		if current_index >= target_tracking_camera.nearby_targets.size():
			current_index = 0
		print(current_index)
		var new_target : Node3D = target_tracking_camera.nearby_targets.get(current_index)

		if new_target != current_target:
			set_lock_target(target_tracking_camera.nearby_targets.get(current_index))
	else:
		target_closest_enemy_to_character()

func on_target_prev(bypass_debounce : bool = false) -> void:
	if current_target == null:
		return
	
	if bypass_debounce == false and plr_debounces.is_debounce_active("target_prev"):
		return
	
	plr_debounces.add_debounce("target_prev")
	plr_debounces.remove_debounce_delayed("target_prev", 0.4)
	
	if target_tracking_camera.nearby_targets.size() > 0:
		var current_index : int = 0
		current_index = target_tracking_camera.nearby_targets.find(current_target)
		
		current_index -= 1
		
		if current_index < 0:
			current_index = target_tracking_camera.nearby_targets.size() - 1
		print(current_index)
		var new_target : Node3D = target_tracking_camera.nearby_targets.get(current_index)
		#if new_target == current_target:
			#target_closest_enemy_to_character()
		if new_target != current_target:
			set_lock_target(target_tracking_camera.nearby_targets.get(current_index))
	else:
		target_closest_enemy_to_character()

func target_closest_enemy_to_character():
	if is_instance_valid(self) == false or get_world_3d() == null:
		return
	
	var scan_shape : SphereShape3D = SphereShape3D.new()
	scan_shape.radius = 50.0
	
	#var combat_chr_scanner : CombatCharacterScanner = CombatCharacterScanner.new()
	#combat_chr_scanner.blacklist = [character, current_target]
	#var closest_enemy = combat_chr_scanner.get_closest_character_to_position(character.global_position, get_world_3d().direct_space_state, scan_shape, character.global_transform, character.chr_layer.get_enemy_layer())
	
	var hurtbox_scanner : HurtBoxScanner = HurtBoxScanner.new()
	hurtbox_scanner.scan_only_in_camera_frustum = false
	
	var closest_hurtbox = hurtbox_scanner.get_closest_hurtbox_to_position(character.global_position, get_world_3d().direct_space_state, scan_shape, character.global_transform, character.chr_layer.get_enemy_layer())
	
	var closest_enemy
	
	print(closest_hurtbox.get_parent_node_3d() )
	if closest_hurtbox != null and closest_hurtbox.get_parent_node_3d() != current_target.get_parent_node_3d():
		closest_enemy = closest_hurtbox.get_parent_node_3d()
	
	print("target outside camera : " + str(closest_enemy))
	if closest_enemy != null and closest_enemy.is_inside_tree():
		set_lock_target(closest_enemy)
	else:
		set_lock_target(null)

func set_lock_target(new_target : Node3D) -> void:
	if current_target != null and current_target.tree_exiting.is_connected(handle_target_tree_exit) == true:
		current_target.tree_exiting.disconnect(handle_target_tree_exit)
	
	current_target = new_target
	character.lock_to_target(new_target)
	#target_reticle.visible = current_target != null
	#inactive_target_reticle.visible = current_target == null and _closest_target != null
	
	if current_target != null and current_target.tree_exiting.is_connected(handle_target_tree_exit) == false:
		current_target.tree_exiting.connect(handle_target_tree_exit.bind(current_target))

func handle_target_tree_exit(_exiting_target : Node3D) -> void:
	if current_target == _exiting_target:
		target_tracking_camera.cleanup_invalid_targets()
		
		on_target_next()

func _input(event: InputEvent) -> void:
	input_events.input_pressed(event)
	input_events.input_released(event)
	#if event.is_pressed():
		#input_events.input_pressed(event)
	#elif event.is_released():
		#input_events.input_released(event)

func handle_camera_rot(delta):
	var chr_movement_camera_influence : float = 0.0
	
	chr_movement_camera_influence = (current_camera.global_basis.x).dot(character.velocity.normalized()) * character.velocity.length() * 0.35
	
	var camera_move_dir : Vector2 = Vector2(-input_events.camera_move_dir.x - chr_movement_camera_influence, -input_events.camera_move_dir.y,)
	
	if current_target != null:
		#camera_move_dir = Vector2.ZERO
		var viewport_size : Vector2 = get_viewport().get_visible_rect().size
		var viewport_center_pos : Vector2 = viewport_size * 0.5
		
		var target_screen_pos : Vector2 = _plr_camera.unproject_position(current_target.global_position)
		var x_correction = -((target_screen_pos - viewport_center_pos).x / viewport_size.x)
		
		#print(x_correction)
		if _plr_camera.is_position_behind(current_target.global_position):
			var camera_look_dir : Vector3 = -_plr_camera.global_basis.z
			camera_move_dir.x = camera_look_dir.signed_angle_to(_plr_camera.global_position.direction_to(current_target.global_position), _plr_camera.global_basis.y) * 10.0
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

func set_input_state(new_state : bool):
	block_input = not new_state
	input_events.block_all_input = block_input

func _process(delta: float) -> void:
	input_events.process(delta)
	
	handle_camera_rot(delta)
	camera_center_offset = camera_arm_center_rest_offset
	camera_arm.target_offset_pos = lerp(camera_arm.target_offset_pos, camera_center_offset, delta * 5.0)

	if current_target != null:
		target_reticle.global_position = current_target.global_position
	
	if _closest_target != null:
		inactive_target_reticle.global_position = _closest_target.global_position
	
	target_reticle.visible = current_target != null
	inactive_target_reticle.visible = current_target == null and _closest_target != null
	
	if block_input == true:
		return
	
	if current_target != null:
		var target_to_camera_dir : Vector3 = (current_target.global_position - _plr_camera.global_position).normalized()
		target_to_camera_dir = Vector3(target_to_camera_dir.x, 0.0, target_to_camera_dir.z)
		
		var target_to_chr_distance = current_target.global_position.distance_to(character.global_position) * 0.9
		
		camera_center_offset = camera_arm_center_rest_offset + ((current_target.global_position - character.global_position) * 0.8) + (target_to_camera_dir * -target_to_chr_distance)
		
		if current_target.global_position.distance_to(character.global_position) > targeting_cancel_distance_treshold:
			#current_target = null
			set_lock_target(null)
	
	if character != null and character.is_current_state("block") and _block_stamina > 0.0:
		_block_stamina = clamp(_block_stamina - delta, 0.0, 100.0)
		
		if is_equal_approx(_block_stamina, 0.0):
			block_stamina_empty.emit()
	else:
		_block_stamina = clampf(_block_stamina + (delta * 5.0), 0.0, 100.0)
	
	if character != null:
		hud._stamina = _block_stamina
		
		hud._stamina_bar_screen_pos = current_camera.unproject_position(character.global_position)
	
	var flat_right_dir = Vector3(current_camera.global_basis.x.x, 0.0, current_camera.global_basis.x.z)
	var flat_forward_dir = Vector3(current_camera.global_basis.z.x, 0.0, current_camera.global_basis.z.z)
	
	var corrected_basis = Basis(flat_right_dir, Vector3.UP, -flat_forward_dir)
	var relative_input_camera_view : Vector3 = corrected_basis * input_events.move_dir
	character.move_dir = relative_input_camera_view
