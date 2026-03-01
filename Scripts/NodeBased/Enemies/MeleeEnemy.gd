extends Node

@export var state_machine : EnemyMeleeStateMachine

var current_callable : Callable
var timeline : Dictionary[float, Callable] = {
	0.0 : idle,
	#5.0 : wander,
	2.0 : attack
}

var time_passed = 0.0
var max_time : float = 2.5

func _ready() -> void:
	state_machine.state_machine_setup()

func _physics_process(delta: float) -> void:
	time_passed += delta
	var nearest_callable_on_timeline = timeline.get(floor(time_passed))
	
	if nearest_callable_on_timeline != null and nearest_callable_on_timeline != current_callable:
		current_callable = nearest_callable_on_timeline
		current_callable.call()
	
	if time_passed > max_time:
		time_passed = 0.0

func idle():
	state_machine.transition_to_state(state_machine.states.get("idle"))

#func wander():
	#state_machine.transition_to_state(state_machine.states.get("wander"))

func attack():
	state_machine.transition_to_state(state_machine.states.get("primary_atk"))
