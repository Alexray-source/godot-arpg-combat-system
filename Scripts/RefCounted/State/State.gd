class_name State extends RefCounted

#@export var transitions : Dictionary[String, Node]
signal state_end()

func on_enter() -> void:
	pass

func on_exit() -> void:
	pass

func state_process(_delta : float) -> void:
	pass

func state_physics_process(_delta : float) -> void:
	pass

func disconnect_all_end_signals() -> void:
	for connection_data in state_end.get_connections():
		var connected_callable : Callable = connection_data.get("callable")
		state_end.disconnect(connected_callable)
