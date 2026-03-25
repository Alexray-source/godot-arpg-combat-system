shader_type spatial;
render_mode ambient_light_disabled;

//Color & Lighting Variables
uniform vec3 BaseColor : source_color = vec3(1.0);
uniform sampler2D BaseTexture : source_color, repeat_enable;
uniform bool useAlpha;

uniform vec3 ShadeColor : source_color = vec3(0.65);
uniform float alphaCutoff = 1.0;

uniform float threshold = 0.0;

//uniform sampler2D SpecularTexture : source_color;
uniform vec3 SpecularTint : source_color = vec3(0.1);
uniform float SpecularOffset = 1.0;

uniform vec3 RimTint : source_color = vec3(0.2,0.2,0.2);
uniform float RimThreshold = 0.25;
uniform float RimSpread = 0.2;
uniform float RimSoftness = 0.0;

uniform bool UseEmission;
uniform sampler2D EmissionTexture : source_color, hint_default_black;
uniform float EmissionStrength = 5.0;

uniform bool UseNormalMap;
uniform sampler2D NormalMap : hint_normal;
uniform float NormalStrength = 1.0;

uniform vec3 custom_light_dir = vec3(0,1.0,0);
uniform float lighting_mode = 0.5;

uniform int uv_div_x : hint_range(1, 100, 1) = 1;
uniform int uv_div_y : hint_range(1, 100, 1) = 1;

uniform int uv_offset_x : hint_range(0, 100, 1) = 0;
uniform int uv_offset_y : hint_range(0, 100, 1) = 0;

void fragment(){
	vec2 uv_div = vec2(float(uv_div_x), float(uv_div_y));
	vec2 uv_tile_size = UV / uv_div;
	vec2 uv_offset = (vec2(1.0,1.0) / uv_div) * vec2(float(uv_offset_x), float(uv_offset_y));
	vec2 base_uv = uv_tile_size + uv_offset;

	vec4 BaseBuffer = texture(BaseTexture, base_uv) * COLOR;
	ALBEDO = BaseBuffer.rgb * BaseColor;
	//ALBEDO = mix(ShadeBuffer.rgb * ShadeColor ,BaseBuffer.rgb * BaseColor, float(diffuse_factor > threshold));
	if (UseNormalMap == true) {
		NORMAL_MAP = texture(NormalMap, base_uv).rgb * NormalStrength;
	}
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
	SPECULAR = 0.0;
	//AO = 0.0;

	if (UseEmission == true) {
		EMISSION = texture(EmissionTexture, base_uv).rgb * EmissionStrength;
	}

	if (useAlpha == true) {
		ALPHA = BaseBuffer.a;
		ALPHA_SCISSOR_THRESHOLD = alphaCutoff;
	}
}

void light() {
	vec3 light_dir = LIGHT;
	light_dir = mix(light_dir, (vec4(custom_light_dir, 1.0) * INV_VIEW_MATRIX).xyz, lighting_mode);

	float inverseRimThreshold = 1.0 - RimThreshold;
	float inverseRimSpread = 1.0 - RimSpread;
	float fresnel = 1.0-pow(dot(VIEW, NORMAL), inverseRimSpread);

//
	//float rimFactor = fresnel * pow(dot(NORMAL, light_dir), inverseRimSpread);
	float rim = smoothstep(inverseRimThreshold - RimSoftness, inverseRimThreshold + RimSoftness, fresnel);

	float diffuse = clamp(dot(NORMAL, light_dir),0.0,1.0) * ATTENUATION;
	//DIFFUSE_LIGHT += step(threshold+0.001, diffuse) * LIGHT_COLOR/PI*0.5;
	float diff_factor = smoothstep(0.0, 0.001, diffuse - threshold);
	float spec_factor = smoothstep(0.0, 0.001, diffuse - (threshold + SpecularOffset));

	vec3 diffuse_lighting = mix(ShadeColor, clamp(LIGHT_COLOR, ShadeColor, vec3(1.0)),diff_factor);
	//vec3 diffuse_lighting = clamp(LIGHT_COLOR/PI*0.5*diff_factor, vec3(0.0), vec3(1.0));

	DIFFUSE_LIGHT = diffuse_lighting + mix(vec3(0.0), RimTint, rim);
	//DIFFUSE_LIGHT *= 0.5;
	SPECULAR_LIGHT += mix(vec3(0.0), vec3(LIGHT_COLOR*SPECULAR_AMOUNT) * SpecularTint, spec_factor) + (vec3(rim*diffuse) * RimTint * LIGHT_COLOR);
}
