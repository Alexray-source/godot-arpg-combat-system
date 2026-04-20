class_name LoadingScreen extends Control

signal load_animation_finished

func load_finished():
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	var tweener = create_tween()
	tweener.finished.connect(load_animation_finished.emit, CONNECT_ONE_SHOT)
	tweener.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)

func load_start():
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tweener = create_tween()
	tweener.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
