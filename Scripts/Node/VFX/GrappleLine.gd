@tool
class_name GrappleLine extends Line3D

enum LinePos {
	START,
	END
}

const ROPE_MAT : ShaderMaterial = preload("uid://kik42uyn1u8p")
const DEFAULT_WIDTH_CURVE : Curve = preload("uid://cbfnut3wdxguy")

signal grapple_anim_finished

var start_node : Node3D
var end_node : Node3D

var _is_animating : bool = false

func _ready() -> void:
	material_override = ROPE_MAT
	width_curve = DEFAULT_WIDTH_CURVE
	points.resize(2)

func animate_grapple():
	_is_animating = true
	
	points[0] = start_node.global_position
	
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	
	tween.tween_method(set_grapple_line_pos.bind(LinePos.END), points[0], end_node.global_position, 0.1)
	tween.finished.connect(func():
		grapple_anim_finished.emit()
		_is_animating = false
	, CONNECT_ONE_SHOT)

func set_grapple_line_pos(target_pos : Vector3, line_pos : LinePos):
	if line_pos == LinePos.START:
		points[0] = target_pos
	else:
		points[1] = target_pos

func set_end_node_animated(new_end_node : Node3D):
	end_node = new_end_node
	animate_grapple()

func _process(_delta: float) -> void:
	if _is_animating == false:
		points[0] = start_node.global_position
		points[1] = end_node.global_position
	rebuild()
