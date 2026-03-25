class_name AnimationAttackData extends AbilityData

@export var dmg : int
@export var anim_tree_oneshot_name : String = "OneShot"
@export var anim_tree_animation_node_name : String = "OverrideAnimation"
@export var animations : Array[String]
@export var atk_type : AtkInfo.AtkType
@export var atk_data : AttackData
@export var targeting_range : float

func create_ability_component() -> AbilityComponent:
	var ability = AnimationAttack.new()
	ability.dmg = dmg
	ability.oneshot_node_name = anim_tree_oneshot_name
	ability.animation_node_name = anim_tree_animation_node_name
	ability.animations = animations
	ability.atk_type = atk_type
	ability.attack_data = atk_data
	ability.targeting_range = targeting_range
	
	return ability
	
