extends FlexibleTween
class_name PositionTween

@export var target_value : Vector3

func play(target_node : Node) -> Tween:
	var tween = super(target_node)
	tween.tween_property(target_node, "position", target_value, tween_time)
	return tween
