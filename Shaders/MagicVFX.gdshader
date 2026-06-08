shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 modulate : source_color = vec4(1.0);
uniform sampler2D albedo_tex : source_color, hint_default_white;
uniform bool red_as_alpha = false;

uniform vec2 uv_scale = vec2(1.0);
uniform vec2 uv_scroll = vec2(0.0);
uniform float uv_rot_scroll = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 time_uv_scroll = (vec2(TIME) * uv_scroll);
	
	float sine = sin(TIME * uv_rot_scroll);
    float cosine = cos(TIME * uv_rot_scroll);
    vec2 uv = UV - vec2(0.5,0.5);
;
	vec2 rotated_uv = vec2(
		uv.x * cosine - uv.y * sine,
		uv.x * sine + uv.y * cosine
	) + vec2(0.5,0.5);
	
	vec4 albedo_tex_color = texture(albedo_tex, rotated_uv * uv_scale + time_uv_scroll);
	
	ALBEDO = albedo_tex_color.rgb * COLOR.rgb  * modulate.rgb;
	
	if (red_as_alpha == true) {
		ALPHA = albedo_tex_color.r * COLOR.a * modulate.a;
	} else {
		ALPHA = albedo_tex_color.a * COLOR.a * modulate.a;
	}
}