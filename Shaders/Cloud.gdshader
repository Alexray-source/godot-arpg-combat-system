shader_type spatial;
render_mode depth_draw_always, cull_disabled;

uniform sampler2D lighting_gradient;
uniform sampler2D softness_gradient;
uniform sampler2D noise_mask;

uniform vec3 rim_tint : source_color = vec3(0.2,0.2,0.2);
uniform float rim_threshold = 0.25;
uniform float rim_spread = 0.2;
uniform float rim_softness = 0.0;
//uniform float softness = 0.5;
uniform float roundness : hint_range(0.0, 1.0, 0.01);
uniform float depth_distance : hint_range(0.0, 100.0, 0.1) = 0.5;
uniform float beers_law : hint_range(0.0, 20.0, 0.1) = 3.0;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest; 

varying vec3 surface_normal;
varying float depth_blend;
varying vec3 vert_color;
varying vec3 light_dir;


void vertex() {
	NORMAL = mix(NORMAL, VERTEX, roundness);
	//radial_normal = (vec4(VERTEX, 1.0) * MODELVIEW_MATRIX).xyz;
	//FRONT
	
	VERTEX += sin(TIME * 0.5 + (length(VERTEX.xyz) * 0.3)) * 1.0;
	vert_color = COLOR.rgb;
}


void fragment() {
	if (FRONT_FACING == false) {
		NORMAL = -NORMAL;
	};
	
	vec3 screen_color = textureLod(screen_texture, SCREEN_UV, 0.0).rgb; 
	float depth = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth, 1.0);
	vec3 pixel_position = upos.xyz / upos.w;
	
	depth_blend = 1.0 - smoothstep(pixel_position.z + depth_distance, pixel_position.z, VERTEX.z);
	depth_blend = exp(depth_blend * -beers_law);
	depth_blend = clamp(pow(depth_blend, 3.0), 0.0, 1.0);
	
	float depth_alpha = 1.0 - depth_blend;
	
	
	float fresnel = dot(TANGENT, NORMAL);
	
	float gradient_result = texture(softness_gradient, vec2(fresnel, 0.0)).r;
	
	ALPHA = clamp(depth_alpha, 0.0, 1.0) * COLOR.a;
	//ALPHA = rim;
	surface_normal = NORMAL;

	//ALBEDO = mix(vec3(0.8), screen_color, depth_blend);
	//ALBEDO = screen_color;
}

void light() {
	float light_dot = dot(surface_normal, LIGHT);
	
	float inverserim_threshold = 1.0 - rim_threshold;
	float inverserim_spread = 1.0 - rim_spread;
	float fresnel = 1.0-dot(VIEW, surface_normal);

	//float rimFactor = fresnel * pow(dot(NORMAL, light_dir), inverserim_spread);
	float rim = smoothstep(inverserim_threshold - rim_softness, inverserim_threshold + rim_softness, fresnel);
	
	vec3 light_gradient_value = texture(lighting_gradient, vec2(smoothstep(-1.0, 1.0, light_dot)  * vert_color.r)).rgb;
	DIFFUSE_LIGHT += (light_gradient_value * LIGHT_COLOR * ATTENUATION / PI) + (rim * rim_tint);
}
