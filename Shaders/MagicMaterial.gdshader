shader_type spatial;
render_mode unshaded, cull_disabled;

uniform float rim_factor = 0.4;
uniform float edge_factor = 0.01;
uniform vec3 color : source_color = vec3(1.0,0.0,0.0);
uniform sampler2D color_mask : source_color, hint_default_white;
uniform vec2 move_factor = vec2(1.0,0.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 color_mask_value = texture(color_mask, UV + (TIME * move_factor)).rgb;
	
	ALBEDO = color * color_mask_value;
	
	float fresnel = dot(NORMAL, VIEW);
	float exp_fresnel = pow(fresnel, rim_factor) + edge_factor;
	
	ALPHA = (1.0 - exp_fresnel) * color_mask_value.r;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
