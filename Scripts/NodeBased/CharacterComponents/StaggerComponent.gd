class_name StaggerComponent extends CharacterComponent

@export var animation_library : String
@export var anim_player : AnimationPlayer
var anims : Array[StringName]

func _ready() -> void:
	anims = anim_player.get_animation_library(animation_library).get_animation_list()

func action() -> void:
	character.dash(-2.0)
	var random_anim = animation_library + "/" + anims.pick_random()
	anim_player.play(random_anim)
