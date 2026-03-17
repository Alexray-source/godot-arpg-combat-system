@tool

class_name Line3D
extends MeshInstance3D


@export_range(0.0, 1.0) var width: float = 0.05:
	set(value):
		width = value
		_try_auto_rebuild()
@export var width_curve: Curve = Curve.new():
	set(value):
		width_curve = value
		_try_auto_rebuild()
@export var gradient: Gradient = Gradient.new():
	set(value):
		gradient = value
		_try_auto_rebuild()
@export var alpha: float = 1.0:
	set(value):
		alpha = value
		_try_auto_rebuild()
@export var use_global_space: bool = false : set = _set_use_global_space
@export var points: PackedVector3Array:
	set(value):
		points = value
		_try_auto_rebuild()

var _vertices: PackedVector3Array
var _tangents: PackedVector3Array
var _colors: PackedColorArray
var _uvs: PackedVector2Array
var _indices: PackedInt32Array
var _arrays: Array
var _last_rebuild_time: float = 0.0
var _auto_rebuild: bool = true


func _init() -> void:

	_arrays.resize(Mesh.ARRAY_MAX)
	_arrays[Mesh.ARRAY_VERTEX] = _vertices;
	_arrays[Mesh.ARRAY_NORMAL] = _tangents;
	_arrays[Mesh.ARRAY_COLOR] = _colors;
	_arrays[Mesh.ARRAY_TEX_UV] = _uvs;
	_arrays[Mesh.ARRAY_INDEX] = _indices;


func _enter_tree() -> void:

	rebuild()

	if Engine.is_editor_hint():
		set_process(true)


func _exit_tree() -> void:

	if Engine.is_editor_hint():
		set_process(false)


func _validate_property(property: Dictionary) -> void:

	if property.name == "mesh":
		property.usage = PROPERTY_USAGE_NONE


func rebuild() -> void:

	if not is_inside_tree():
		return

	if not mesh:
		mesh = ArrayMesh.new()

	var am := mesh as ArrayMesh
	am.clear_surfaces()

	var point_count := points.size()
	if point_count < 2:
		return

	_vertices.resize(point_count * 2)
	_tangents.resize(point_count * 2)
	_colors.resize(point_count * 2)
	_uvs.resize(point_count * 2)
	_indices.resize(point_count * 2)

	var half_width := width / 2
	var inv_global_tf: Transform3D

	if use_global_space:
		inv_global_tf = global_transform.inverse()

	for i in point_count:

		var j0 := i * 2
		var j1 := j0 + 1

		var p := points[i]
		if use_global_space:
			p = inv_global_tf * p
		_vertices[j0] = p
		_vertices[j1] = p

		var tangent: Vector3
		if i == 0:
			tangent = (points[i + 1] - p).normalized()
		elif i == point_count - 1:
			tangent = (p - points[i - 1]).normalized()
		else:
			tangent = (p - points[i - 1]).lerp(points[i + 1] - p, 0.5).normalized()
		_tangents[j0] = tangent
		_tangents[j1] = tangent

		var u := float(i) / (point_count - 1)

		var c := gradient.sample(u)
		c.a *= alpha
		_colors[j0] = c
		_colors[j1] = c

		var v := half_width * width_curve.sample(u)
		_uvs[j0] = Vector2(u, -v)
		_uvs[j1] = Vector2(u, v)

		_indices[j0] = j0
		_indices[j1] = j1

	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, _arrays)


func _try_auto_rebuild() -> void:

	if Engine.is_editor_hint() and _auto_rebuild:
		rebuild()


func _set_use_global_space(use: bool) -> void:

	use_global_space = use
	if Engine.is_editor_hint():
		rebuild()
