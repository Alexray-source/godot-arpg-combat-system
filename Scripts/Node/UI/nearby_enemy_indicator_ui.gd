class_name NearbyEnemyIndicatorsUI extends Control

const INDICATOR_ITEM : PackedScene = preload("res://Scenes/UI/enemy_indicator_item.tscn")

@export var target_tracking_camera : TargetTrackingCamera
@export var camera : Camera3D
@export var track_origin : Node3D

var nearby_targets : Array[Node3D]
var nearby_target_indicators : Dictionary[Node3D, Control]

func _ready() -> void:
	target_tracking_camera.target_added.connect(add_indicator)
	target_tracking_camera.target_removed.connect(remove_indicator)

func add_indicator(new_target : Node3D):
	var new_indicator : Control = INDICATOR_ITEM.instantiate()
	add_child(new_indicator)
	new_indicator.global_position = size * 0.5
	
	nearby_target_indicators[new_target] = new_indicator

func remove_indicator(removing_target : Node3D):
	var indicator = nearby_target_indicators.get(removing_target)
	
	if indicator == null:
		return
	
	nearby_target_indicators.erase(removing_target)
	indicator.queue_free()

func _process(_delta: float) -> void:
	if track_origin == null:
		return
	
	for target : Node3D in nearby_target_indicators:
		if is_instance_valid(target) == false:
			continue
		
		var indicator = nearby_target_indicators[target]
		
		indicator.visible = not camera.is_position_in_frustum(target.global_position)
		
		var forward_direction : Vector3 = -camera.global_basis.z
		var up_direction : Vector3 = camera.global_basis.y
		var target_direction : Vector3 = track_origin.global_position.direction_to(target.global_position)
		
		var axis_plane = Plane(up_direction)
		var forward_flat = axis_plane.project(forward_direction)
		var up_flat = axis_plane.project(target_direction)
		
		indicator.rotation = -forward_flat.signed_angle_to(up_flat, up_direction)
