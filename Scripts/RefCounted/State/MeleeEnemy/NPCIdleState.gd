class_name NPCIdleState extends EnemyNPCState

func on_enter() -> void:
	character.move_dir = Vector3.ZERO
