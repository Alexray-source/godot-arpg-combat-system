extends CutsceneChrAction
class_name CutsceneChrTeleport

var teleport_target : Node3D
var randomnness_radius : float = 0.0

var teleport_delay : float = 0.15

var teleport_start_vfx_scene : PackedScene
var teleport_end_vfx_scene : PackedScene


func perform_action():
	if teleport_start_vfx_scene != null:
		var teleport_start_vfx = teleport_start_vfx_scene.instantiate()
		teleport_start_vfx.top_level = true
		chr.add_child(teleport_start_vfx)
		teleport_start_vfx.global_position = chr.global_position
		
		chr.get_tree().create_timer(teleport_delay).timeout.connect(teleport.bind(chr, teleport_target.global_position))

func teleport(_chr, _position):
	_chr.global_position = _position + Vector3(randf_range(-randomnness_radius,randomnness_radius), 0.0, randf_range(-randomnness_radius,randomnness_radius))
	
	if teleport_end_vfx_scene != null:
		var teleport_end_vfx : Node3D = teleport_end_vfx_scene.instantiate()
		teleport_end_vfx.top_level = true
		_chr.add_child(teleport_end_vfx)
		teleport_end_vfx.global_position = _chr.global_position
