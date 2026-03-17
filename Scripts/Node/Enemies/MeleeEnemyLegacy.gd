extends Node

@export var character : CombatCharacter
@export var detect_range : float = 30.0
@export var forced_attack_range : float = 4.0

@export var state_machine : EnemyMeleeStateMachine

var hurtbox_scanner : HurtBoxScanner
var scan_shape : SphereShape3D
var closest_hurtbox : HurtBox
var scan_timer : Timer

var current_callable : Callable
var timeline : Dictionary[float, Callable] = {
	0.0 : strafe,
	2.0 : chase_attack
}

var time_passed = 0.0
var max_time : float = 15.0

func _ready() -> void:
	scan_shape = SphereShape3D.new()
	scan_shape.radius = detect_range
	
	hurtbox_scanner = HurtBoxScanner.new()
	
	state_machine.state_machine_setup()
	
	scan_timer = Timer.new()
	scan_timer.one_shot = false
	scan_timer.timeout.connect(scan_timer_tick)
	add_child(scan_timer)
	scan_timer.start(0.25)
	
	state_machine.states.get("chase_attack").state_end.connect(func():
		current_callable = attack
		current_callable.call()
		)
	
	character.chr_died.connect(func():
		queue_free()
	, CONNECT_ONE_SHOT)


func scan_timer_tick() -> void:
	closest_hurtbox = hurtbox_scanner.get_closest_hurtbox_to_position(character.global_position, character.get_world_3d().direct_space_state, scan_shape, character.global_transform, character.chr_layer.get_enemy_layer())

func _physics_process(delta: float) -> void:
	if closest_hurtbox == null:
		if current_callable != idle:
			current_callable = idle
			current_callable.call()
		return
	
	#elif (closest_hurtbox.global_position - character.global_position).length() > detect_range * 0.5:
		#if current_callable != faraway_chase:
			#current_callable = faraway_chase
			#current_callable.call()
		#return
	
	else:
		#print("timeline")
		time_passed += delta
		var nearest_callable_on_timeline = timeline.get(floor(time_passed))
		
		if nearest_callable_on_timeline != null and nearest_callable_on_timeline != current_callable:
			current_callable = nearest_callable_on_timeline
			current_callable.call()
		
		if time_passed > max_time:
			reset_timeline()

func idle() -> void:
	state_machine.transition_to_state(state_machine.states.get("idle"))

func strafe() -> void:
	state_machine.transition_to_state(state_machine.states.get("strafe"))
	#state_machine.states.get("strafe").state_end.connect(strafe_to_attack, CONNECT_ONE_SHOT)

#func strafe_to_attack() -> void:
	#if closest_hurtbox != null and (closest_hurtbox.global_position - character.global_position).length() <= forced_attack_range:
		#state_machine.transition_to_state(state_machine.states.get("chase_attack"))

func faraway_chase() -> void:
	state_machine.transition_to_state(state_machine.states.get("chase_attack"))
	reset_timeline()

func chase_attack() -> void:
	state_machine.transition_to_state(state_machine.states.get("chase_attack"))
	

func reset_timeline() -> void:
	#print("reset")
	time_passed = 0.0

func attack() -> void:
	#state_machine.current_state.disconnect_all_end_signals()
	state_machine.transition_to_state(state_machine.states.get("primary_atk"))
	#state_machine.transition_to_state(state_machine.states.get("strafe"))
	reset_timeline()
