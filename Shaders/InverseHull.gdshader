shader_type spatial;
render_mode unshaded, cull_front, shadows_disabled;

uniform float OutlineSize = 0.2;
uniform vec3 OutlineColor : source_color;

instance uniform float opacity = 1.0;

varying float z_dist;

void vertex() {
	float FOV_in_radians = atan(-1.0 / PROJECTION_MATRIX[1][1]) * 2.0;
	
	//NOTE TO SELF: ORDER MATTERS!!!
	vec3 vertex_view_space = (MODELVIEW_MATRIX * vec4(VERTEX,1.0)).xyz;
	
	VERTEX += NORMAL * length(vertex_view_space) * 0.01;
}

void fragment() {
	ALBEDO = OutlineColor;
	ALPHA = clamp(opacity, 0.0, 1.0);
}
