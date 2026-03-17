extends Node

@export var character : CombatCharacter
@export var detect_range : float = 30.0
@export var forced_attack_range : float = 4.0

@export var state_machine : EnemyMeleeStateMachine

var hurtbox_scanner : HurtBoxScanner
var scan_shape : SphereShape3D
var closest_hurtbox : HurtBox
var scan_timer : Timer

var _state_index : int = 0

var state_pattern : Array = [
	"strafe",
	"chase",
	"primary_atk",
	#"chase",
	#"primary_atk"
]

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
	
	change_state(0)

func change_state(index : int):
	_state_index = index
	if index >= state_pattern.size():
		_state_index = 0
	
	var state_key = state_pattern[_state_index]
	print(state_key)
	var target_state : State = state_machine.get_state_by_key(state_key)
	
	target_state.state_end.connect(
		change_state.bind(_state_index+1),
	CONNECT_ONE_SHOT)
	
	state_machine.transition_to_state(target_state)

func scan_timer_tick() -> void:
	closest_hurtbox = hurtbox_scanner.get_closest_hurtbox_to_position(character.global_position, character.get_world_3d().direct_space_state, scan_shape, character.global_transform, character.chr_layer.get_enemy_layer())
	
	character.combat_target_override = closest_hurtbox
