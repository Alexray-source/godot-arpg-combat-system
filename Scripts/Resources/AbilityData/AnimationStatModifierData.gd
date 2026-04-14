class_name AnimationStatModifierData extends AbilityData

@export var animation : String
@export var animation_node_name : String = "OverrideAnimation"
@export var oneshot_node_name : String = "OneShot"
@export var stat_modifiers : Dictionary[String, StatModifier]

func create_ability_component() -> AbilityComponent:
	var anim_stat_modifier : AnimationStatModifier = AnimationStatModifier.new()
	anim_stat_modifier.animation = animation
	anim_stat_modifier.animation_node_name = animation_node_name
	anim_stat_modifier.oneshot_node_name = oneshot_node_name
	anim_stat_modifier.stat_modifiers = stat_modifiers
	
	return anim_stat_modifier
