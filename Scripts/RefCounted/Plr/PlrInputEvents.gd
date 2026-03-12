class_name PlrInputEvents extends RefCounted

enum InputMode {
	KEYBOARD,
	GAMEPAD
}

var input_mode : InputMode = InputMode.KEYBOARD
var move_dir : Vector3
var block_move_input : bool = false
var camera_move_dir : Vector2

signal jump_input
signal dash_input
signal primary_atk_input
signal special_atk1_input
signal special_atk2_input
signal special_atk3_input
signal grapple_input
signal grapple_mode_toggle

var signal_mapping : Dictionary[String, Signal] = {
	"chr_jump" : jump_input,
	"chr_dash" : dash_input,
	"chr_primary_atk" : primary_atk_input,
	"chr_special_atk1" : special_atk1_input,
	"chr_special_atk2" : special_atk2_input,
	"chr_special_atk3" : special_atk3_input,
	"chr_grapple" : grapple_input,
	"grapple_toggle_mode" : grapple_mode_toggle
}

func input_pressed(input : InputEvent):
	for action_name in signal_mapping:
		if input.is_action_pressed(action_name):
			signal_mapping[action_name].emit()
	
	if input_mode == InputMode.KEYBOARD and input is InputEventMouseMotion:
		camera_move_dir = input.screen_relative


func process(_delta : float):
	if block_move_input == true:
		move_dir = Vector3.ZERO
		return
	
	var move_dir_xz_plane = Input.get_vector("chr_move_left", "chr_move_right", "chr_move_bwd", "chr_move_fwd")
	move_dir = Vector3(move_dir_xz_plane.x, 0.0, move_dir_xz_plane.y)
	
