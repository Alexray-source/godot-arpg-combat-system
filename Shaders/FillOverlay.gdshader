shader_type spatial;
render_mode unshaded, cull_front, shadows_disabled, world_vertex_coords;

uniform float OutlineSize = 0.2;
uniform vec3 OutlineColor : source_color;

instance uniform float opacity = 1.0;

//varying float distance_thickness = 0.0;

void vertex() {
	float FOV_in_radians = atan(-1.0 / PROJECTION_MATRIX[1][1]) * 2.0;
	float dist = distance(CAMERA_POSITION_WORLD, (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz) * 2.0;
	VERTEX += NORMAL * (OutlineSize * dist * FOV_in_radians * 0.01);
	//VERTEX += NORMAL * OutlineSize * 0.1;
}

void fragment() {
	ALBEDO = OutlineColor;
	ALPHA = clamp(opacity, 0.0, 1.0);
}
