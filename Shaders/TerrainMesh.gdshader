shader_type spatial;

//#include "includes/fbm_noise.gdshaderinc"
#include "includes/default_pbr.gdshaderinc"
#include "includes/rim.gdshaderinc"

//uniform bool use_mesh_normal = false;
//uniform sampler2D mesh_normal_tex;

//uniform float uv_grass_scale = 0.2;
//uniform float uv_rock_scale = 15.0;
uniform float uv_splat_textures_scale = 0.2;

uniform bool use_splat_map = false;
uniform sampler2D splat_map : filter_linear;

//uniform sampler2DArray textures_albedo : source_color, filter_linear;
//uniform sampler2DArray textures_normal : filter_linear;

group_uniforms Material.A;
uniform sampler2D albedo_a : source_color, filter_linear;
uniform sampler2D normalmap_a : filter_linear;
uniform float uv_scale_a = 0.1;

group_uniforms Material.B;
uniform sampler2D albedo_b : source_color, filter_linear;
uniform sampler2D normalmap_b : filter_linear;
uniform float uv_scale_b = 0.1;

group_uniforms Material.C;
uniform sampler2D albedo_c : source_color, filter_linear;
uniform sampler2D normalmap_c : filter_linear;
uniform float uv_scale_c = 0.1;

instance uniform bool use_vertex_color = false;
instance uniform float instance_scale = 1.0;

varying vec3 vert_pos;
varying vec3 vert_normal;
varying vec2 ground_uv;

void vertex() {
	vec4 wpos = MODEL_MATRIX * vec4(VERTEX, 1);
	ground_uv = wpos.xz;
	ROUGHNESS = 1.0;
}

void fragment() {
	vec2 scaled_splat_textures_uv = ground_uv * uv_splat_textures_scale;
	
	vec3 color_a = texture(albedo_a, vec2(ground_uv * uv_scale_a)).rgb;
	vec3 color_b = texture(albedo_b, vec2(ground_uv * uv_scale_b)).rgb;
	vec3 color_c = texture(albedo_c, vec2(ground_uv * uv_scale_c)).rgb;
	
	vec3 normal_a = texture(normalmap_a, vec2(ground_uv * uv_scale_a)).rgb;
	vec3 normal_b = texture(normalmap_b, vec2(ground_uv * uv_scale_b)).rgb;
	vec3 normal_c = texture(normalmap_c, vec2(ground_uv * uv_scale_c)).rgb;
	
	vec4 vertex_color = COLOR;
	float vertex_color_sum = (vertex_color.r + vertex_color.g + vertex_color.b);
	
	vec3 albedo = color_a;
	
	if (use_vertex_color == true){
		albedo = (
			vertex_color.r * color_a + 
			vertex_color.g * color_b +
			vertex_color.b * color_c) / vertex_color_sum;
	}
	//vec3 normal_map = (
		//vertex_color.r * normal_a +
		//vertex_color.g * normal_b +
		//vertex_color.b * normal_c +
		//vertex_color.a * normal_d) / vertex_color_sum;

	if (use_splat_map == true) {
		vec4 splat_data = texture(splat_map, UV);
		
		float splat_data_sum = (splat_data.r + splat_data.g + splat_data.b);
		float splat_mask = clamp(splat_data_sum, 0.0, 1.0);
		float inverse_mask = 1.0 - splat_mask;
		
		
		// inverse_mask prevents division by zero.
		// Otherwise we would get a NaN infecting all other calculations.
		// splat_mask blending ensures that the vertex color blending is still applied when splat_data_sum == 0.
		vec3 splat_albedo = (
		splat_data.r * color_a +
		splat_data.g * color_b +
		splat_data.b * color_c) / (splat_data_sum + inverse_mask);
		
		//vec3 splat_normal_map = (
		//splat_data.r * normal_a +
		//splat_data.g * normal_b +
		//splat_data.b * normal_c +
		//splat_data.a * normal_d) / (splat_data_sum + inverse_mask);
		
		albedo = mix(albedo, splat_albedo, splat_mask);
		//normal_map = mix(normal_map, splat_normal_map, splat_mask);
	}
	ALBEDO = albedo;
	SPECULAR = 0.5;
	//NORMAL_MAP = normal_map;
}

//void light() {
	//vec3 s = get_specular(NORMAL, LIGHT, VIEW, ALBEDO, ROUGHNESS, METALLIC, SPECULAR_AMOUNT);
	//float d = get_diffuse(NORMAL, LIGHT, VIEW, ROUGHNESS);
	//vec3 rim = get_rim(VIEW, NORMAL, ATTENUATION, LIGHT_COLOR * ALBEDO, LIGHT);
	//DIFFUSE_LIGHT += (LIGHT_COLOR * ATTENUATION * d);
	//SPECULAR_LIGHT += (LIGHT_COLOR * ATTENUATION * s) + rim;
	//SPECULAR_LIGHT += (LIGHT_COLOR * ATTENUATION * s);
//}