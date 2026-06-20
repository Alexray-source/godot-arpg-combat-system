class_name AnimationPlayerTrigger
extends Trigger

@export var animation_player : AnimationPlayer
@export var animation_name : String

func execute(_params : Dictionary):
	animation_player.play(animation_name)
