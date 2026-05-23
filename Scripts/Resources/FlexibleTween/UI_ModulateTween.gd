extends FlexibleTween
class_name UI_ModulateTween

@export var use_start_value : bool = false
@export var start_value : Color
@export var target_value : Color

func play(target_node : Node) -> Tween:
	var tween = super(target_node)

	if use_start_value == true:
		target_node.modulate = start_value
	
	tween.tween_property(target_node, "modulate", target_value, tween_time)
	return tween
