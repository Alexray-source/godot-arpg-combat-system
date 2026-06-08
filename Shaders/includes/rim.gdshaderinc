uniform vec3 RimTint : source_color = vec3(1.0,1.0,1.0);
uniform float RimThreshold = 0.25;
uniform float RimSpread = 2.5;
uniform float RimSoftness = 0.01;

vec3 get_rim(vec3 view, vec3 normal, float attenuation, vec3 light_color, vec3 light_dir) {
	float inverseRimThreshold = 1.0 - RimThreshold;
	float inverseRimSpread = 1.0 - RimSpread;
	float fresnel = 1.0-pow(clamp(dot(view, normal),0.0,1.0), inverseRimSpread);

	float rim = smoothstep(inverseRimThreshold - RimSoftness, inverseRimThreshold + RimSoftness, fresnel);

	return (rim * RimTint * attenuation * light_color);
}