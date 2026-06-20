extends Node3D

@export var cutscene_actions : Dictionary[String, Variant]

@export_subgroup("Nodes")
@export var character : BaseCharacter

func _ready() -> void:
	character.set_state("no_movement")
	
	GlobalSignals.global_generic_event_fired.connect(on_global_event)

func on_global_event(event_name : String):
	if cutscene_actions.has(event_name):
		cutscene_actions[event_name]
