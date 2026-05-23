extends Node

@export var base_chr : BaseCharacter
@export var chr_mesh : Node3D
@export var bypass : bool = false

func _process(delta: float) -> void:
	var lean_dir : float = 0.0
	
	if bypass == false and base_chr.is_current_state("ground_movement"):
		lean_dir = -base_chr.move_dir.signed_angle_to(base_chr.velocity.normalized(), Vector3.UP) * 2.5
		lean_dir = clamp(lean_dir, -14.0,14.0)
	
	chr_mesh.rotation.z = lerp(chr_mesh.rotation.z, lean_dir, delta * 5.0)
