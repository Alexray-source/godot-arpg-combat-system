class_name SlashVFX extends Node3D

@export var rot_speed : float = 4.0
@export var lifetime : float = 0.6
@export var mesh_instance : MeshInstance3D

func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	
	var tween = create_tween()
	tween.tween_property(mesh_instance, "instance_shader_parameters/alpha", 0.0, 0.25)
	tween.finished.connect(queue_free)

func _process(delta: float) -> void:
	rotate_object_local(Vector3.UP, rot_speed * delta)
