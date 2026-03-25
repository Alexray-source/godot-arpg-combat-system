class_name StaggerComponent extends CharacterComponent

@export var animation_node_name : String = "OverrideAnimation"
@export var oneshot_node_name : String = "OneShot"
@export var anim_tree : AnimationTree
@export var stagger_anims : Array[StringName]

func action() -> void:
	var one_shot_property_path = "parameters/" + oneshot_node_name
	
	character.dash(-2.0)
	var random_anim = stagger_anims.pick_random()
	anim_tree.tree_root.get_node(animation_node_name).animation = random_anim
	anim_tree.set(one_shot_property_path + "/fadein_time", 0.0)
	anim_tree.set(one_shot_property_path + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
