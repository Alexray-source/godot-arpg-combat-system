shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D albedo : source_color;
uniform sampler2D noise_mask;
uniform sampler2D mask;
uniform float strength = 5.0;
instance uniform float alpha = 1.0;

void vertex() {
	float noise_value = texture(noise_mask, UV + vec2(TIME)).r - 0.5;
	VERTEX += noise_value * 0.02;
}

void fragment() {
	float noise_value = texture(noise_mask, UV + vec2(TIME)).r;
	float mask_value = texture(mask, UV).r;
	vec4 color = texture(albedo, UV + vec2(TIME * 0.25, TIME));
	ALBEDO = color.rgb * strength;
	ALPHA = color.a * alpha * mask_value * COLOR.a * noise_value;
}