extends Trigger
class_name CameraShakeTriggerProximity

@export var scan_center : Node3D
@export var scan_radius : float = 10.0
@export var shake_info : ShakeInfo
@export var chr_layer : CharacterLayer

var hurtbox_scanner : HurtBoxScanner = HurtBoxScanner.new()
var scan_shape : SphereShape3D = SphereShape3D.new()

func _ready() -> void:
	scan_shape.radius = scan_radius

func execute(_params : Dictionary):
	if scan_radius <= 0.0:
		GlobalSignals.shake_all_cameras.emit(shake_info)
		return
	
	
	var result = hurtbox_scanner.get_nearby_hurtboxes_from_position(get_viewport().world_3d.direct_space_state, scan_shape, scan_center.global_transform, chr_layer.get_collision_layer())
	if result != null:
		GlobalSignals.shake_all_cameras.emit(shake_info)
