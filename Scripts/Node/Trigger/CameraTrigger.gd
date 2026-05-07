class_name CameraTrigger
extends Trigger

@export var reset_to_default : bool
@export var target_camera : Camera3D

@export var tween_time : float = 0.0

var cached_transform : Transform3D
var cached_fov : float

func _ready() -> void:
	if target_camera != null:
		cached_transform = target_camera.global_transform
		cached_fov = target_camera.fov

func set_current_camera(camera : Camera3D):
	camera.make_current()
	GlobalSignals.camera_changed.emit(camera)

func execute(_params : Dictionary):
	var current_cam = get_viewport().get_camera_3d()
	
	var default_camera : Camera3D = get_tree().get_first_node_in_group("default_camera")
	if tween_time <= 0.0:
		if reset_to_default == true and get_tree().get_first_node_in_group("default_camera") != null:
			set_current_camera(default_camera)
			#target_camera = default_camera
			#cached_transform = default_camera.global_transform
			#cached_fov = default_camera.fov
		else:
			set_current_camera(target_camera)
	
	else:
		if reset_to_default == true and get_tree().get_first_node_in_group("default_camera") != null:
			target_camera = default_camera

		var temp_camera = Camera3D.new()
		add_child(temp_camera)
		
		temp_camera.global_transform = current_cam.global_transform
		temp_camera.fov = current_cam.fov
		temp_camera.reset_physics_interpolation()
		set_current_camera(temp_camera)
		
		var tween = get_tree().create_tween()
		
		tween.finished.connect(func():
			set_current_camera(target_camera)
			, CONNECT_ONE_SHOT)
		
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_parallel(true)
		tween.tween_property(temp_camera, "global_position", target_camera.global_position, tween_time)
		tween.tween_property(temp_camera, "global_basis", target_camera.global_basis, tween_time)
		tween.tween_property(temp_camera, "fov", target_camera.fov, tween_time)
		
