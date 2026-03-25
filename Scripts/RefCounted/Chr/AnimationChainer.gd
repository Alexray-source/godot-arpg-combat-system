class_name AnimationChainer extends RefCounted

var anim_tree : AnimationTree
#var attacks_library_name : String

var animation_node_name : String
var oneshot_node_name : String
var animations : Array[String]
var current_anim_index : int = 0

signal animation_finished

func setup() -> void:
	#animations = anim_player.get_animation_library(attacks_library_name).get_animation_list()
	anim_tree.animation_finished.connect(on_animation_finished)

func reset_chain() -> void:
	current_anim_index = 0

func resume_chain() -> void:
	print("playing override")
	var one_shot_property_path = "parameters/" + oneshot_node_name
	#anim_player.play(animations.get(current_anim_index))
	anim_tree.tree_root.get_node(animation_node_name).animation = animations.get(current_anim_index)
	anim_tree.set(one_shot_property_path + "/fadein_time", 0.0)
	anim_tree.set(one_shot_property_path + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	current_anim_index += 1
	
	if current_anim_index >= animations.size():
		reset_chain()

func on_animation_finished(anim_name : StringName):
	#print(anim_name)
	#var sliced_name = anim_name.get_slice("/", 1)
	
	if animations.find(anim_name) != -1:
		animation_finished.emit()
