shader_type spatial;
render_mode cull_disabled;

uniform sampler2D albedo : source_color;
uniform sampler2D noise_mask;
uniform float strength = 5.0;
instance uniform float alpha = 1.0;

void vertex() {
	float noise_value = texture(noise_mask, UV + vec2(TIME)).r - 0.5;
	VERTEX += noise_value * 0.02;
}

void fragment() {
	float noise_value = texture(noise_mask, UV + vec2(TIME)).r;
	vec4 color = texture(albedo, UV + vec2(TIME * 0.25, 0.0));
	ALBEDO = vec3(0.0);
	EMISSION = color.rgb * strength;
	ALPHA = color.a * alpha * COLOR.a * noise_value;
}