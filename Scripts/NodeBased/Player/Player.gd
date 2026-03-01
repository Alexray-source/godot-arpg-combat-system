extends Node3D

@export var character : CombatCharacter
@export var plr_state_machine : PlrCharacterStateMachine

var current_camera : Camera3D

var input_events : PlrInputEvents

func _ready() -> void:
	input_events = PlrInputEvents.new()
	
	plr_state_machine.input_events = input_events
	plr_state_machine.state_machine_setup()
	
	plr_state_machine.transition_to_state(plr_state_machine.get_state_by_key("movement"))
	
	character.primary_attack_component.atk_finished.connect(on_atk_anim_end)
	character.special_attack1_component.atk_finished.connect(on_atk_anim_end)
	
	input_events.primary_atk_input.connect(on_primary_atk)
	input_events.special_atk1_input.connect(on_special_atk.bind(1))
	

func on_atk_anim_end():
	plr_state_machine.transition_to_state(plr_state_machine.get_state_by_key("movement"))

func on_primary_atk() -> void:
	print(character.debounces.is_debounce_active("primary_atk"))
	if character is CombatCharacter and character.debounces.is_debounce_active("primary_atk") == false:
		plr_state_machine.transition_to_state(plr_state_machine.get_state_by_key("primary_atk"))

func on_special_atk(atk_index : int) -> void:
	var debounce_string = character.get_special_atk_debounce_string(atk_index)
	if character is CombatCharacter and character.debounces.is_debounce_active(debounce_string) == false:
		plr_state_machine.transition_to_state(plr_state_machine.get_state_by_key("special_atk" + str(atk_index)))

func _input(event: InputEvent) -> void:
	input_events.input_pressed(event)

#func _physics_process(delta: float) -> void:
