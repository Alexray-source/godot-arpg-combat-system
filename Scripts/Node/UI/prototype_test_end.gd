extends Panel

@export var show_time : float = 2.0
@export var main_section : Control
@export var promo_section : Control

func _ready() -> void:
	main_section.modulate = Color(1.0,1.0,1.0)
	promo_section.modulate = Color(1.0,1.0,1.0,0.0)
	
	await get_tree().create_timer(show_time).timeout
	
	var tween = get_tree().create_tween()
	tween.tween_property(main_section, "modulate", Color(1.0,1.0,1.0,0.0), 0.15)
	tween.tween_property(promo_section, "modulate", Color(1.0,1.0,1.0,1.0), 0.15)
	
