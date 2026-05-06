shader_type spatial;
render_mode unshaded, cull_front, shadows_disabled, world_vertex_coords;

uniform float OutlineSize = 0.2;
uniform vec3 OutlineColor : source_color;

//varying float distance_thickness = 0.0;

void vertex() {
	//float FOV_in_radians = atan(-1.0 / PROJECTION_MATRIX[1][1]) * 2.0;
	//float dist = distance(CAMERA_POSITION_WORLD, (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz);
	//VERTEX += NORMAL * (OutlineSize * dist * FOV_in_radians * 0.01);
	VERTEX += NORMAL * OutlineSize * 0.01;
}

void fragment() {
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, FRAGCOORD.z, 1.0);
	vec3 pixel_position = upos.xyz / upos.w;
	//distance_thickness = -pixel_position.z;
	ALBEDO = OutlineColor;
}
