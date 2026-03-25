class_name StateMachine extends Node

var states : Dictionary[String, State]
@export var debug : bool = false

var current_state : State

signal state_changed(new_state : State)

#func _ready() -> void:
func state_machine_setup():
	pass

func _process(delta: float) -> void:
	if current_state != null:
		current_state.state_process(delta)

func _physics_process(delta: float) -> void:
	if current_state != null:
		current_state.state_physics_process(delta)

func get_state_by_key(state_key : String):
	return states.get(state_key)

func transition_to_state(new_state : State):
	#if new_state == current_state:
		#return

	if current_state != null:
		current_state.on_exit()
	
	current_state = new_state
	new_state.on_enter()
	state_changed.emit(new_state)
	
	if debug == true:
		print("New State: " + str(new_state.get_script().get_global_name()))
	

func transition_to_state_by_key(new_state_key : String):
	var new_state = get_state_by_key(new_state_key)
	transition_to_state(new_state)
