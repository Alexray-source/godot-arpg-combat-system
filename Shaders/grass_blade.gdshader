// Copyright © 2025 Cory Petkovsek, Roope Palmroos, and Contributors.

shader_type spatial;

render_mode skip_vertex_transform;

#include "includes/default_pbr.gdshaderinc"
#include "includes/grass_utils.gdshaderinc"

varying vec3 node_pos;
varying vec3 vertex_normal;

//instance uniform vec3 normal_vector = vec3(0.0,1.0,0.0);

// A lot of hard coded things here atm.
void vertex() {
	// World space vertex
	vec3 w_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	w_vertex.xz += get_wind_offset(w_vertex, VERTEX);

	VERTEX = (VIEW_MATRIX * vec4(w_vertex, 1.0)).xyz;
	vertex_normal = NORMAL;
	node_pos = NODE_POSITION_WORLD;
	NORMAL = get_normal();
}

void fragment() {
	ALBEDO = get_grass_color(COLOR, NODE_POSITION_WORLD);
	ROUGHNESS = get_roughness(COLOR.rgb);
	SPECULAR = get_specular_value(COLOR.rgb);
}

void light() {
	DIFFUSE_LIGHT += ATTENUATION * LIGHT_COLOR / PI;
}
