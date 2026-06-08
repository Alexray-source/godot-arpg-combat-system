const float INV_PI = 0.318309;

float diffuse_burley(
	in float cNdotL,
	in float cNdotV,
	in float cHdotL,
	in float sigma // Roughness.
)
{
	// https://media.disneyanimation.com/uploads/production/publication_asset/48/asset/s2012_pbs_disney_brdf_notes_v3.pdf 
	float FD90 = 2.0 * sigma * cHdotL * cHdotL - 0.5;
	
	float fd_L = 1.0 + (FD90) * pow(1.0 - cNdotL, 5.0);
	float fd_V = 1.0 + (FD90) * pow(1.0 - cNdotV, 5.0);
	
	return  fd_V * fd_L * cNdotL * INV_PI;
}

vec3 specular_schlick_ggx(
	in float cNdotL,
	in float cNdotV,
	in float cHdotN,
	in float cHdotL,
	in vec3 rho, // Diffuse Color.
	in float sigma, // Roughness.
	in float m, // Metallic.
	in float s // Metallic Specular.
)
{
	float a = sigma * sigma; // Variance.
	float a2 = a * a;
	
	/* Normal Distribution Function (Trowbridge-Reitz) */
	float D = 1.0 + (a2 - 1.0) * cHdotN * cHdotN;
	
	D = a2 / (PI * D * D);
	
	/* Geometric Function (Implicit) */
	float G = 0.5 / mix(2.0 * cNdotL * cNdotV, cNdotL + cNdotV, a);
	
	/* Fresnel Function (Schlick’s Approximation) */
	float dielectric = 0.16 * s * s;
	
	vec3 f0 = mix(vec3( dielectric ), rho, vec3( m )); 
	float f90 = clamp(dot(f0, vec3(16.5)), m, 1.0);
	
	vec3 F = f0 + (f90 - f0) * pow(1.0 - cHdotL, 5.0);
	
	return max(D * G * F * cNdotL, 0.0);
}

float get_diffuse(vec3 normal, vec3 light, vec3 view, float roughness) {
	vec3 h = normalize(view + light); // Halfway Vector.
	
	float NdotL = dot(normal, light); // [-1.0, 1.0].
	float NdotV = dot(normal, view); // [-1.0, 1.0].
	
	float HdotN = dot(h, normal); // [-1.0, 1.0].
	float HdotL = dot(h, light); // [-1.0, 1.0].
	
	float cNdotL = max(NdotL, 0.0); // [0.0, 1.0].
	float cNdotV = max(NdotV, 0.0); // [0.0, 1.0].
	
	float cHdotN = max(HdotN, 0.0); // [0.0, 1.0].
	float cHdotL = max(HdotL, 0.0); // [0.0, 1.0].
	
	return diffuse_burley(cNdotL, cNdotV, cHdotL, roughness);
}

vec3 get_specular(vec3 normal, vec3 light, vec3 view, vec3 albedo, float roughness, float metallic, float metallic_specular) {
	vec3 h = normalize(view + light); // Halfway Vector.
	
	float NdotL = dot(normal, light); // [-1.0, 1.0].
	float NdotV = dot(normal, view); // [-1.0, 1.0].
	
	float HdotN = dot(h, normal); // [-1.0, 1.0].
	float HdotL = dot(h, light); // [-1.0, 1.0].
	
	float cNdotL = max(NdotL, 0.0); // [0.0, 1.0].
	float cNdotV = max(NdotV, 0.0); // [0.0, 1.0].
	
	float cHdotN = max(HdotN, 0.0); // [0.0, 1.0].
	float cHdotL = max(HdotL, 0.0); // [0.0, 1.0].
	
	return specular_schlick_ggx(cNdotL, cNdotV, cHdotN, cHdotL, albedo, roughness, metallic, metallic_specular);
}