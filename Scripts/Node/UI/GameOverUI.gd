class_name GameOverUI extends Control

signal retry
signal quit

@export var continue_btn : Button
@export var quit_btn : Button

func _ready() -> void:
	continue_btn.pressed.connect(retry.emit, CONNECT_ONE_SHOT)
	quit_btn.pressed.connect(quit.emit, CONNECT_ONE_SHOT)
