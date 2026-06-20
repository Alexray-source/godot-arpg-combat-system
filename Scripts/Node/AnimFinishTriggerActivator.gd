class_name AnimFinishTriggerActivator
extends Node

@export var animation_player : AnimationPlayer
@export var animation_name : String
@export var target_trigger : Trigger

func _ready() -> void:
	animation_player.animation_finished.connect(on_animation_finished)

func on_animation_finished(anim_name : String):
	if anim_name == animation_name:
		target_trigger.execute({})
