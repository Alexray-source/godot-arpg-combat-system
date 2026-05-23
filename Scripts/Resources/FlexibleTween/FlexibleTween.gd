extends Resource
class_name FlexibleTween

@export var transition : Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR
@export var easing : Tween.EaseType = Tween.EaseType.EASE_OUT
@export var tween_time : float = 1.0

func play(_target_node : Node) -> Tween:
	var tween : Tween = _target_node.create_tween()
	tween.set_ease(easing)
	tween.set_trans(transition)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	return tween
