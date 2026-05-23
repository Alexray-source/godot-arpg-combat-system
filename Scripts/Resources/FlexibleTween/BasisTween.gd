extends FlexibleTween
class_name BasisTween

@export var target_value : Basis

func play(target_node : Node) -> Tween:
	var tween = super(target_node)
	tween.tween_property(target_node, "basis", target_value, tween_time)
	return tween
