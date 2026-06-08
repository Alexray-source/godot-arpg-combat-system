@tool
extends Control
class_name SplatmapBrushEditorDock

enum DrawMode {
	IDLE,
	DRAW
}

enum DrawChannel {
	RED,
	GREEN,
	BLUE,
	BLACK
}

@export var idle_btn : Button
@export var draw_btn : Button

@export var red_ch_btn : Button
@export var green_ch_btn : Button
@export var blue_ch_btn : Button
@export var black_ch_btn : Button

@export var apply_btn : Button

@export var size_slider : Slider

var draw_mode : DrawMode = DrawMode.IDLE
var current_draw_channel : DrawChannel = DrawChannel.RED
var draw_size : int = 15.0

signal apply_btn_pressed

func _enter_tree() -> void:
	idle_btn.pressed.connect(set_draw_mode.bind(DrawMode.IDLE))
	draw_btn.pressed.connect(set_draw_mode.bind(DrawMode.DRAW))
	
	red_ch_btn.pressed.connect(set_drawing_channel.bind(DrawChannel.RED))
	green_ch_btn.pressed.connect(set_drawing_channel.bind(DrawChannel.GREEN))
	blue_ch_btn.pressed.connect(set_drawing_channel.bind(DrawChannel.BLUE))
	black_ch_btn.pressed.connect(set_drawing_channel.bind(DrawChannel.BLACK))
	apply_btn.pressed.connect(func():
		apply_btn_pressed.emit()
	)
	
	size_slider.value_changed.connect(set_draw_size)
	
func set_draw_size(new_size : int):
	draw_size = new_size

func set_draw_mode(requested_mode : DrawMode):
	draw_mode = requested_mode
	print("New draw mode:" + str(draw_mode))

func set_drawing_channel(requested_channel : DrawChannel):
	current_draw_channel = requested_channel
	print("New draw channel:" + str(current_draw_channel))
