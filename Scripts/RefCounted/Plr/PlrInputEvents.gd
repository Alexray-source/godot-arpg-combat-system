class_name PlrInputEvents extends RefCounted

enum InputMode {
	KEYBOARD,
	GAMEPAD
}

var input_mode : InputMode = InputMode.KEYBOARD
var move_dir : Vector3
var block_move_input : bool = false
var block_all_input : bool = false
var camera_move_dir : Vector2

signal jump_input
signal dash_input
signal block_start
signal block_end
signal sprint_start
signal sprint_end

signal primary_atk_input
signal secondary_atk_input
signal special_atk1_input
signal special_atk2_input
signal special_atk3_input
signal special_atk4_input

signal grapple_input
signal grapple_enemy_input
#signal switch_grapple_mode

signal target_lock
signal target_next
signal target_prev


var signal_mapping : Dictionary[String, Signal] = {
	"chr_jump" : jump_input,
	"chr_dash" : dash_input,
	"chr_sprint" : sprint_start,
	"chr_block" : block_start,
	"chr_primary_atk" : primary_atk_input,
	"chr_secondary_atk" : secondary_atk_input,
	"chr_grapple" : grapple_input,
	#"chr_grapple_enemy" : grapple_enemy_input,
	#"chr_grapple_mode" : switch_grapple_mode,
	"plr_target_lock" : target_lock,
	"plr_target_next" : target_next,
	"plr_target_prev" : target_prev
}

var signal_mapping_end : Dictionary[String, Signal] = {
	"chr_block" : block_end,
	"chr_sprint" : sprint_end
}

var special_atks : Dictionary[String, Signal] = {
	"chr_special_atk1" : special_atk1_input,
	"chr_special_atk2" : special_atk2_input,
	"chr_special_atk3" : special_atk3_input,
	"chr_special_atk4" : special_atk4_input
}

var grapple_characters : bool = true

func setup() -> void:
	#print(Input.get_connected_joypads().size() > 0)
	change_input_mode(Input.get_connected_joypads().size() > 0)
	Input.joy_connection_changed.connect(func(_device : int, is_connected : bool):
		change_input_mode.bind(is_connected)
	)

func disconnect_all_events():
	for input_signal_key in signal_mapping:
		var input_signal : Signal = signal_mapping[input_signal_key]
		var connections = input_signal.get_connections()
		
		for connection : Dictionary in connections:
			var callable = connection.get("callable")
			input_signal.disconnect(callable)
		
		
func change_input_mode(is_gamepad_connected : bool):
	if is_gamepad_connected:
		input_mode = InputMode.GAMEPAD
	else:
		input_mode = InputMode.KEYBOARD


func input_pressed(input : InputEvent):
	if block_all_input == true:
		return
	
	grapple_characters = not (Input.get_action_strength("chr_move_bwd") > 0.5)
	
	for action_name in signal_mapping:
		if input.is_action_pressed(action_name) and Input.is_action_pressed("gamepad_action_btn") == false:
			signal_mapping[action_name].emit()
		
	
	for special_attack_action_name in special_atks:
		if input_mode == InputMode.GAMEPAD:
			if input.is_action_pressed(special_attack_action_name) and Input.is_action_pressed("gamepad_action_btn") == true:
				special_atks[special_attack_action_name].emit()
		else:
			if input.is_action_pressed(special_attack_action_name):
				special_atks[special_attack_action_name].emit()
	
	#if input.is_action_pressed("chr_grapple_object"):
		#if Input.get_action_strength("chr_move_bwd") > 0.8:
			#grapple_object_input.emit()
		#else:
			#grapple_enemy_input.emit()
	
	if input_mode == InputMode.KEYBOARD and input is InputEventMouseMotion:
		camera_move_dir = input.screen_relative

func input_released(input : InputEvent):
	if block_all_input == true:
		return
	
	for action_name in signal_mapping_end:
		if input.is_action_released(action_name) and Input.is_action_pressed("gamepad_action_btn") == false:
			signal_mapping_end[action_name].emit()

func process(_delta : float):
	if block_move_input == true or block_all_input == true:
		move_dir = Vector3.ZERO
		return
	
	var move_dir_xz_plane = Input.get_vector("chr_move_left", "chr_move_right", "chr_move_bwd", "chr_move_fwd")
	move_dir = Vector3(move_dir_xz_plane.x, 0.0, move_dir_xz_plane.y)
	
	if input_mode == InputMode.GAMEPAD:
		camera_move_dir = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down") * 10.0
	
