uniform vec3 grass_color : source_color = vec3(0.45, 0.5, 0.17);
uniform vec3 grass_sec_color : source_color = vec3(0.45, 0.5, 0.17);

uniform vec2 wind_direction = vec2(1.0,0.0);
uniform float wind_intensity = 1.0;
uniform float wind_speed = 2.0;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) *
            43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    // Four corners in 2D of a tile
    float a = random(uv_index);
    float b = random(uv_index + vec2(1.0, 0.0));
    float c = random(uv_index + vec2(0.0, 1.0));
    float d = random(uv_index + vec2(1.0, 1.0));

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix(a, b, blur.x) +
            (c - a) * blur.y * (1.0 - blur.x) +
            (d - b) * blur.x * blur.y;
}

vec2 get_wind_offset(vec3 w_vertex, vec3 vertex) {
	//return vec2(0.0,0.0);
	float force = wind_intensity * vertex.y;
	// Add some cheap jitter at high wind values
	//force -= fract(force * 256.0) * force * 0.2;
	// Curve the result
	//force = pow(force, 0.707);

	float big_wobble = 0.25 + sin(TIME * wind_speed * 0.5) * wind_intensity * 0.1 * noise(w_vertex.xz);
	vec2 direction = normalize(wind_direction);

	float lateral_wobble = 0.5 + ((sin((w_vertex.x * 10.0) + TIME * 3.0 * wind_speed)) * wind_intensity * 0.1);
	return (vec2(direction.x, direction.y) * lateral_wobble + big_wobble) * force;
}

vec4 get_vertex_color(vec4 vert_color, vec3 vertex) {
	return mix(vert_color, vert_color * 1.5, vertex.y);
}

vec3 get_grass_color(vec4 vert_color, vec3 node_pos) {
	//float noise_value = texture(noise_color_var, node_pos.xz * 0.01).r;
	float rand_value = noise(node_pos.xz * 0.4);
	// Hard coded color.
	//vec3 grass_gradient = mix(grass_color, grass_sec_color, vert_color.r);
	vec3 grass_random_color = mix(grass_color, grass_sec_color * (1.0 + (rand_value * 0.5)), vert_color.r);
	vec4 grass_albedo = vec4(grass_random_color,1.0);
	//grass_albedo *= pow(vert_color, vec4(1.5));
	return grass_albedo.rgb;
}

vec3 get_normal() {
	return vec3(0.0,1.0,0.0);
}

float get_roughness(vec3 vert) {
	//return mix(1.0,0.5, vert.r);
	return 1.0;
}

float get_specular_value(vec3 vert) {
	return 0.5;
}