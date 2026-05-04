extends Panel

@export var duration : float = 2.0

func _ready() -> void:
	modulate = Color(1.0,1.0,1.0,0.0)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1.0,1.0,1.0,1.0), duration)
