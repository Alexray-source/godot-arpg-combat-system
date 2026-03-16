class_name TargetTrackingCamera extends Camera3D

@export var camera_scan_area : Area3D
@export var camera_frustum_shape : CollisionShape3D
@export var camera_scan_radius : float = 10.0

var targets_in_view : Array[Node3D]

func _ready() -> void:
	recalculate_perspective_shape()
	camera_scan_area.area_entered.connect(on_area_camera_view_entered)
	camera_scan_area.area_exited.connect(on_area_camera_view_exited)

func recalculate_perspective_shape() -> void:
	var pyramid_shape_rid : RID = get_pyramid_shape_rid()
	
	var camera_shape_points = PhysicsServer3D.shape_get_data(pyramid_shape_rid)
	var convex_shape : ConvexPolygonShape3D = ConvexPolygonShape3D.new()
	convex_shape.points = camera_shape_points
	
	for point_id in convex_shape.points.size():
		var point = convex_shape.points[point_id]
		var normalized_point = point.normalized()
		convex_shape.points[point_id] = normalized_point * camera_scan_radius
	
	camera_frustum_shape.shape = convex_shape

func on_area_camera_view_entered(entered_area : Area3D):
	if entered_area is HurtBox:
		targets_in_view.append(entered_area)
		cleanup_invalid_targets()

func on_area_camera_view_exited(exited_area : Area3D):
	if exited_area is HurtBox and targets_in_view.find(exited_area) != -1:
		targets_in_view.erase(exited_area)
		cleanup_invalid_targets()

func cleanup_invalid_targets():
	var new_target_list : Array[Node3D]
	
	for target in targets_in_view:
		if target != null and not target.is_queued_for_deletion():
			new_target_list.append(target)
	
	targets_in_view = new_target_list
