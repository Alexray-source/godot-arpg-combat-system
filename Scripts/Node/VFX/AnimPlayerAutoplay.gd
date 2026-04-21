class_name AnimPlayerAutoplay extends Node

@export var anim_player : AnimationPlayer
@export var anim_name : String

func _ready() -> void:
	anim_player.play(anim_name)
