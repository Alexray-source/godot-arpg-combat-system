class_name CharacterBlockState extends CharacterState

var block_count : int
var block_threshold_for_parry : int = 3

func on_enter() -> void:
	print("block")
	character.velocity = Vector3.ZERO
	#character.move_dir = Vector3.ZERO

func increment_block_count() -> void:
	block_count += 1

func reset_block_count() -> void:
	block_count = 0

func state_physics_process(_delta : float) -> void:
	character.move_and_slide()
