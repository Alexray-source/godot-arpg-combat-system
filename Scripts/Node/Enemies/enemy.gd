class_name Enemy extends Node3D

@export var character : CombatCharacter
@export var behavior_tree : BT_Root

signal died

func _ready() -> void:
	character.chr_died.connect(handle_death, CONNECT_ONE_SHOT)

func set_behavior_tree_active(new_state : bool):
	behavior_tree.set_active(new_state)

func handle_death():
	died.emit()
	queue_free()
