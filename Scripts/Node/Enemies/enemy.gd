class_name Enemy extends Node3D

@export var character : CombatCharacter
@export var behavior_tree : BT_Root
@export var drop : PackedScene

var dead_state : CharacterDeadState

signal died

func _ready() -> void:
	dead_state = character.state_machine.get_state_by_key("dead")
	dead_state.state_end.connect(cleanup)
	character.chr_died.connect(handle_death, CONNECT_ONE_SHOT)

func set_behavior_tree_active(new_state : bool):
	behavior_tree.set_active(new_state)

func handle_death():
	character.set_state("dead")
	died.emit()

func cleanup():
	if drop != null:
		var instanced_drop : Node3D = drop.instantiate()
		get_tree().current_scene.add_child(instanced_drop)
		instanced_drop.global_position = character.global_position
	
	queue_free()
