class_name Enemy extends Node3D

@export var character : CombatCharacter

signal died

func _ready() -> void:
	character.chr_died.connect(handle_death, CONNECT_ONE_SHOT)

func handle_death():
	died.emit()
	queue_free()
