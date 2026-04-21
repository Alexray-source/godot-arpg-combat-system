class_name GameOverUI extends Control

signal retry
signal quit

@export var continue_btn : Button
@export var quit_btn : Button

func _ready() -> void:
	continue_btn.pressed.connect(retry.emit, CONNECT_ONE_SHOT)
	quit_btn.pressed.connect(quit.emit, CONNECT_ONE_SHOT)
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("controller_ui_continue"):
		retry.emit()
	elif event.is_action_pressed("controller_ui_back"):
		quit.emit()
		
