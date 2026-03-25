class_name GrappleAbilityData extends AbilityData

@export var anim_tree_oneshot_name : String = "OneShot"
@export var anim_tree_animation_node_name : String = "OverrideAnimation"
@export var animations : Array[String]
@export var targeting_range : float = 20.0
@export var target_characters : bool = false

func create_ability_component() -> AbilityComponent:
	var ability = GrappleComponent.new()
	#ability
	ability.should_target_characters = target_characters
	ability.animation_node_name = anim_tree_animation_node_name
	ability.oneshot_node_name = anim_tree_oneshot_name
	ability.animations = animations
	ability.targeting_range = targeting_range
	
	return ability
	
