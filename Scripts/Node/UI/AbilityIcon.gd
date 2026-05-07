class_name AbilityIcon extends TextureRect

var fill_progress_factor : float:
	set(_value):
		fill_progress_factor = _value
		update_bar(_value)

@export var invert_visual_progress : bool

@export_subgroup("Nodes")
@export var progress_bar : ProgressBar
@export var activate_layer : Control

func activate_effect():
	activate_layer.modulate = Color(1.0,1.0,1.0)
	scale = Vector2(1.4,1.4)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_parallel(true)
	tween.tween_property(activate_layer, "modulate", Color(1.0,1.0,1.0,0.0), 0.5)
	tween.tween_property(self, "scale", Vector2(1.0,1.0), 0.5)
	

func insufficient_energy_notification():
	activate_layer.modulate = Color(1.0, 0.0, 0.0, 1.0)
	scale = Vector2(1.4,1.4)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_parallel(true)
	tween.tween_property(activate_layer, "modulate", Color(1.0, 0.0, 0.0, 0.0), 0.5)
	tween.tween_property(self, "scale", Vector2(1.0,1.0), 0.5)

func update_bar(new_fill_factor : float):
	if progress_bar == null:
		return
	
	if invert_visual_progress == true:
		progress_bar.value = 1.0 - new_fill_factor
	else:
		progress_bar.value = new_fill_factor
