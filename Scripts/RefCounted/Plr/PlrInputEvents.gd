class_name PlrInputEvents extends RefCounted

var move_dir : Vector3
var block_move_input : bool = false

signal jump_input
signal primary_atk_input
signal special_atk_input

var signal_mapping : Dictionary[String, Signal] = {
	"chr_jump" : jump_input,
	"chr_primary_atk" : primary_atk_input
}

func input_pressed(input : InputEvent):
	for action_name in signal_mapping:
		if input.is_action_pressed(action_name):
			signal_mapping[action_name].emit()

func process(_delta : float):
	if block_move_input == true:
		move_dir = Vector3.ZERO
		return
	
	var move_dir_xz_plane = Input.get_vector("chr_move_left", "chr_move_right", "chr_move_bwd", "chr_move_fwd")
	move_dir = Vector3(move_dir_xz_plane.x, 0.0, move_dir_xz_plane.y)
