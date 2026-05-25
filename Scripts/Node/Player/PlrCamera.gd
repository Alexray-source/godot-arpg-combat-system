class_name TargetTrackingCamera extends Node

@export var camera : Camera3D
@export var camera_scan_radius : float = 10.0
@export var layer_owner : CharacterLayer
var _nearby_targets_scan_area : Area3D
var _nearby_targets_scan_shape : CollisionShape3D

#var targets_in_view : Array[Node3D]
var nearby_targets : Array[Node3D]

var _closest_node_tracker : ClosestNode3DTracker

signal target_added(new_target : Node3D)
signal target_removed(new_target : Node3D)
signal closest_target_changed(new_target : Node3D)

func _ready() -> void:
	_nearby_targets_scan_area = Area3D.new()
	_nearby_targets_scan_area.collision_mask = layer_owner.get_enemy_layer()
	
	_nearby_targets_scan_shape = CollisionShape3D.new()
	initialize_nearby_target_scan_shape()

	_nearby_targets_scan_area.add_child(_nearby_targets_scan_shape)
	
	camera.add_child(_nearby_targets_scan_area)
	
	_nearby_targets_scan_area.area_entered.connect(on_body_nearby_area_entered)
	_nearby_targets_scan_area.area_exited.connect(on_body_nearby_area_exited)
	
	_closest_node_tracker = ClosestNode3DTracker.new()
	_closest_node_tracker.camera = camera
	_closest_node_tracker.only_in_camera = true
	_closest_node_tracker.node_list = nearby_targets
	_closest_node_tracker.closest_node_changed.connect(closest_target_changed.emit)

func _physics_process(delta: float) -> void:
	_closest_node_tracker.scan_origin = camera.global_position
	_closest_node_tracker.poll(delta)

func initialize_nearby_target_scan_shape():
	var sphere_shape : SphereShape3D = SphereShape3D.new()
	sphere_shape.radius = camera_scan_radius
	
	_nearby_targets_scan_shape.shape = sphere_shape

func on_body_nearby_area_entered(entered_body : Node3D):
	if entered_body.is_in_group("targetable"):
		nearby_targets.append(entered_body)
		target_added.emit(entered_body)
		cleanup_invalid_targets()

func on_body_nearby_area_exited(exited_body : Node3D):
	if exited_body.is_in_group("targetable") and nearby_targets.find(exited_body) != -1:
		nearby_targets.erase(exited_body)
		target_removed.emit(exited_body)
		cleanup_invalid_targets()

func cleanup_invalid_targets():
	var new_target_list : Array[Node3D]
	
	for target in nearby_targets:
		if target != null and is_instance_valid(target) and not target.is_queued_for_deletion():
			new_target_list.append(target)
	
	nearby_targets = new_target_list
	_closest_node_tracker.node_list = nearby_targets
