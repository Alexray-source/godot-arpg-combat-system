//float random(vec2 uv) {
    //return fract(sin(dot(uv.xy,
        //vec2(12.9898,78.233))) *
            //43758.5453123);
//}
//
//float noise(vec2 uv) {
    //vec2 uv_index = floor(uv);
    //vec2 uv_fract = fract(uv);
//
    //// Four corners in 2D of a tile
    //float a = random(uv_index);
    //float b = random(uv_index + vec2(1.0, 0.0));
    //float c = random(uv_index + vec2(0.0, 1.0));
    //float d = random(uv_index + vec2(1.0, 1.0));
//
    //vec2 blur = smoothstep(0.0, 1.0, uv_fract);
//
    //return mix(a, b, blur.x) +
            //(c - a) * blur.y * (1.0 - blur.x) +
            //(d - b) * blur.x * blur.y;
//}
//
//float fbm(vec2 uv) {
    //int octaves = 3;
    //float amplitude = 0.5;
    //float frequency = 3.0;
	//float value = 0.0;
	//
    //for(int i = 0; i < octaves; i++) {
        //value += amplitude * noise(frequency * uv);
        //amplitude *= 0.5;
        //frequency *= 2.0;
    //}
    //return value;
//}

vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) + 0.5;
}