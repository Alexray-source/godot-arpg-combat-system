class_name CharacterDetector extends Area3D

@export var chr_layer : CharacterLayer

signal chr_entered(entered_chr : BaseCharacter)
signal chr_exited(entered_chr : BaseCharacter)

func _ready() -> void:
	collision_mask = chr_layer.get_collision_layer()
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)

func on_body_entered(entered_body : Node3D):
	if entered_body is BaseCharacter:
		chr_entered.emit(entered_body)

func on_body_exited(exited_body : Node3D):
	if exited_body is BaseCharacter:
		chr_exited.emit(exited_body)
