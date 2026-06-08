shader_type sky;

uniform vec3 GroundColor : source_color;
uniform vec3 UnderHorizonColor : source_color;

uniform vec3 HorizonColor : source_color;
uniform vec3 SkyColor : source_color = vec3(1.0);

uniform float HorizonScale = 1.0;
uniform float HorizonOffset = 0.0;

uniform float SunDiskScale = 0.2;
uniform float SunGlowScale = 0.5;
uniform float SunGlowStrength = 1.0;
uniform vec3 SunColor : source_color = vec3(1.0);

uniform vec3 CloudsColor : source_color = vec3(0.8);
uniform sampler2D CloudNoise;
uniform sampler2D CloudDetailNoise;
uniform sampler2D CloudMaskNoise;

void sky() {
	float horizon = EYEDIR.y * HorizonScale + HorizonOffset;
	vec3 groundGradient = mix(GroundColor, UnderHorizonColor, clamp((horizon + 0.4), 0.0, 1.0));
	vec3 horizonGradient = mix(groundGradient, HorizonColor, clamp((horizon+0.2), 0.0, 1.0));
	
	vec3 skyGradient =  mix(horizonGradient, SkyColor, clamp(horizon, 0.0, 1.0));
	
	float cos_theta = dot(EYEDIR, LIGHT0_DIRECTION);
	float sunDir = distance(EYEDIR, LIGHT0_DIRECTION);
	float sunPos = 1.0 - clamp(sunDir / SunDiskScale, 0.0, 1.0);
	float sunGlowPos = 1.0 - clamp(sunDir / (SunGlowScale), 0.0, 1.0);
	
	vec3 sun = vec3(sunPos/ SunDiskScale) * LIGHT0_ENERGY * SunColor;
	vec3 sun_glow =  (1.0- clamp(vec3(sunDir), vec3(0.0), vec3(1.0))) * SunColor * SunGlowStrength;
	
	vec3 skyWithSun =  mix(skyGradient + (sun_glow), sun, clamp(horizon, 0.0, 1.0));
	
	vec3 noiseFactor = texture(CloudNoise, EYEDIR.xz * 0.2 / EYEDIR.y + TIME*0.002).rgb;
	vec3 noiseDetail = texture(CloudDetailNoise, EYEDIR.xz / EYEDIR.y + TIME*0.01).rgb;
	vec3 noiseMask = texture(CloudMaskNoise, EYEDIR.xz / (EYEDIR.y*8.0) + TIME*0.0007).rgb;
	
	vec3 cloudLayer = mix(noiseDetail, noiseFactor, noiseMask.r);
	
	vec3 skyWithClouds = mix(skyWithSun, CloudsColor, cloudLayer.r);

	COLOR = mix(skyWithSun, skyWithClouds, clamp(vec3(EYEDIR.y).r, 0.0, 1.0));

}
