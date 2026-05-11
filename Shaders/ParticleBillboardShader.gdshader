shader_type spatial;
render_mode unshaded;

uniform sampler2D particle_tex;
uniform float color_multiplier = 1.0;

//positive depth moves toward the camera in world units
uniform float depth_offset = 0.0;


void vertex() {
	mat4 mat_world = mat4(
			normalize(INV_VIEW_MATRIX[0]),
			normalize(INV_VIEW_MATRIX[1]),
			normalize(INV_VIEW_MATRIX[2]),
			MODEL_MATRIX[3]);
	mat_world = mat_world * mat4(
			vec4(cos(INSTANCE_CUSTOM.x), -sin(INSTANCE_CUSTOM.x), 0.0, 0.0),
			vec4(sin(INSTANCE_CUSTOM.x), cos(INSTANCE_CUSTOM.x), 0.0, 0.0),
			vec4(0.0, 0.0, 1.0, 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_MATRIX = VIEW_MATRIX * mat_world;

	// Billboard Keep Scale: Enabled
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
			vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),
			vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),
			vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));

	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	vec4 tex_buffer = texture(particle_tex, UV);
	ALBEDO = tex_buffer.rgb * COLOR.rgb * color_multiplier;
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;
	EMISSION = tex_buffer.rgb * COLOR.rgb * color_multiplier;
	ALPHA = COLOR.a * tex_buffer.a;
	
	//view to world(global) fragment position set to world_position
	vec3 world_position = vec4(INV_VIEW_MATRIX * vec4(VERTEX,1)).xyz;
	//set direction fragment from vertex to camera in world space
	vec3 dir2cam  = normalize(CAMERA_POSITION_WORLD - world_position);
	//move fragment towards camera in world(global) space
	world_position += dir2cam * depth_offset;
	//transform world_position from world(global) to view space
	//then transform world_position from view to clip(ndc) space
	vec4 ndc_offset = PROJECTION_MATRIX * VIEW_MATRIX * vec4(world_position,1);
	//normalize ndc_offset.z and set depth
	DEPTH = ndc_offset.z/ndc_offset.w;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
