extends FlexibleTween
class_name PropTween

@export var target_property : String
@export var optional_start_value : Variant
@export var target_value : Variant

func play(target_node : Node) -> Tween:
	var tween = super(target_node)
	
	if optional_start_value != null:
		target_node.set(target_property, optional_start_value)
	
	tween.tween_property(target_node, target_property, target_value, tween_time)
	return tween
