shader_type spatial;

render_mode
	blend_mix,
	cull_disabled,
	shadows_disabled,
	unshaded,
	depth_draw_never,
	world_vertex_coords;


uniform float softness : hint_range(0, 1) = 0.0;
uniform sampler2D albedo_texture : hint_default_white;
uniform vec2 uv_scale = vec2(1.0,0.5);
uniform vec2 uv_offset = vec2(0.0, 0.5);
uniform vec2 uv_time_scale = vec2(0.0);


void vertex() {
	vec3 p = (VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 t = (VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	vec3 b = normalize(cross(p, t));
	p += UV.y * b;
	VERTEX = (INV_VIEW_MATRIX * vec4(p, 1.0)).xyz;
	UV.y = sign(UV.y);
}

void fragment() {
	vec2 scaled_uv = UV * uv_scale;
	vec2 scrolling_uv = scaled_uv + (vec2(TIME) * uv_time_scale);
	
	vec4 texture_color = texture(albedo_texture, scrolling_uv + uv_offset).rgba;
	
	ALBEDO = COLOR.rgb * texture_color.rgb;
	ALPHA = COLOR.a * texture_color.a;
	if (softness > 0.0)
		ALPHA *= clamp((1.0 - abs(UV.y)) / max(0.01, softness), 0.0, 1.0);
}
