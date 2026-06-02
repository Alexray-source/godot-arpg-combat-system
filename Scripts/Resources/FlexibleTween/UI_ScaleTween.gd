extends FlexibleTween
class_name UI_ScaleTween

@export var use_start_value : bool = false
@export var start_value : Vector2
@export var target_value : Vector2

func play(target_node : Node) -> Tween:
	var tween = super(target_node)
	
	if use_start_value == true:
		target_node.scale = start_value
	
	tween.tween_property(target_node, "scale", target_value, tween_time)
	return tween
