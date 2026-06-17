shader_type spatial;

uniform vec3 baseColor : source_color;
uniform vec3 rimColor : source_color;
uniform vec3 shineThroughColor : source_color;
uniform sampler2D noise_tex;
uniform float rimPower = 1.0;

varying float noise_val;
varying float fresnel1;
uniform sampler2D SCREEN_TEX : hint_screen_texture, filter_linear_mipmap;

void vertex() {
	// Called for every vertex the material is visible on.
	noise_val = texture(noise_tex, VERTEX.xz).r;
}

void fragment() {
	float fresnel = 1.0 - dot(VIEW, NORMAL);
	fresnel1 = pow(1.0 - dot(VIEW, NORMAL), rimPower);
	vec3 screen_color = textureLod(SCREEN_TEX, SCREEN_UV, 5.0).rgb;
	
	screen_color *= 500.0 * smoothstep(0.4, 1.0, length(screen_color));
	
	METALLIC = 0.0;
	ROUGHNESS = 0.0;
	ALBEDO = mix(baseColor, rimColor, fresnel);
	ALBEDO = mix(ALBEDO, screen_color * ALBEDO, 0.1);
	//EMISSION = fresnel1 * screen_color * shineThroughColor;
}

void light() {
	float light_dot = clamp(dot(LIGHT, NORMAL), 0.0, 1.0);
	vec3 diffuse_light = light_dot * ATTENUATION * LIGHT_COLOR * 0.5;
	
	DIFFUSE_LIGHT += diffuse_light;
	SPECULAR_LIGHT += (smoothstep(0.0,1.0, (1.0 - (dot(LIGHT, NORMAL)+1.0))) * shineThroughColor);
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
}
