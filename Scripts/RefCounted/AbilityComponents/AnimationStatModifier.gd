class_name AnimationStatModifier extends AbilityComponent

var _animation_chainer : AnimationChainer

var animation : String
var animation_node_name : String
var oneshot_node_name : String
var stat_modifiers: Dictionary[String, StatModifierData]

func setup() -> void:
	_animation_chainer = AnimationChainer.new()
	_animation_chainer.animations = [animation]
	_animation_chainer.anim_tree = anim_tree
	_animation_chainer.oneshot_node_name = oneshot_node_name
	_animation_chainer.animation_node_name = animation_node_name

func action() -> void:
	_animation_chainer.resume_chain()

func ability_event() -> void:
	if character is CombatCharacter:
		for modifier_key in stat_modifiers:
			var stat_modifier = stat_modifiers[modifier_key]
			character.add_stat_modifier(modifier_key, stat_modifier)
	
	ability_finished.emit()
