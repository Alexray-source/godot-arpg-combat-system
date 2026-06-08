shader_type spatial;
//render_mode unshaded;

uniform sampler2D noise_texture;

group_uniforms depth;
uniform int layers : hint_range(0, 64, 1) = 8;
uniform float depth_amount = 1.0;
uniform float fade_amount : hint_range(0.0, 16.0, 0.01) = 1.0;

varying vec3 surface_normal; 

float parallax(float depth, vec3 n, vec3 t, vec3 v) {
	vec3 normal = normalize(n);
	vec3 tangent = normalize(t);
	vec3 bitangent = cross(normal, tangent);
	vec3 view = normalize(v);
	vec3 view_tangent = vec3(dot(view, tangent), dot(view, bitangent), dot(view, normal));
	return view_tangent.z;
	//vec2 offset = (view_tangent.xy / max(view_tangent.z, 0.001)) * depth;
	//offset = vec2(-offset.x, offset.y);
	//
	//return offset;
}

void vertex() {
	surface_normal = NORMAL;
	NORMAL = VERTEX * vec3(5.0,1.0,1.0);
}

void fragment() {
	float value = 0.0;
	value = parallax(0.0, surface_normal, TANGENT, VIEW);
	//for(int i = 0; i < layers; i++){
		//float t = float(i) / float(layers);
		//float depth = t * depth_amount;
		////
		////vec2 noise_uv = UV + parallax(depth, NORMAL, TANGENT, VIEW);
		////float noise = texture(noise_texture, noise_uv).r;
		////
		//////float layer_value = overlay(circle, noise);
		////noise = smoothstep(0.0, 0.5, noise);
		////
		////noise *= pow(t, fade_amount);
		//
		//value = parallax(depth, NORMAL, TANGENT, VIEW);
	//}
	
	ALPHA = clamp(value, 0.0, 1.0);
}
