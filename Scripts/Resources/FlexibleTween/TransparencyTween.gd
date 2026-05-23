extends FlexibleTween
class_name TransparencyTween

@export var target_value : float

func play(target_node : Node) -> Tween:
	var tween = super(target_node)
	tween.tween_property(target_node, "transparency", target_value, tween_time)
	return tween
