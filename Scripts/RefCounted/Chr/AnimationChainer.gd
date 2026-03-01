class_name AnimationChainer extends RefCounted

var anim_player : AnimationPlayer
#var attacks_library_name : String

var animations : Array[StringName]
var current_anim_index : int = -1

signal animation_finished

func setup() -> void:
	#animations = anim_player.get_animation_library(attacks_library_name).get_animation_list()
	anim_player.animation_finished.connect(on_animation_finished)

func resume_chain() -> void:
	current_anim_index += 1
	
	if current_anim_index >= animations.size():
		current_anim_index = 0
	
	anim_player.play(animations.get(current_anim_index))

func on_animation_finished(anim_name : StringName):
	#print(anim_name)
	#var sliced_name = anim_name.get_slice("/", 1)
	
	if animations.find(anim_name) != -1:
		animation_finished.emit()
