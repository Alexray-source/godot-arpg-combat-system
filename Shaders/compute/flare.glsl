#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, binding = 0, set = 0) uniform image2D screen_image;
layout(binding = 0, set = 1) uniform sampler2D lens_flare_tex;
layout(binding = 0, set = 2) uniform sampler2D core_lens_flare_tex;

layout(push_constant, std430) uniform Params {
    vec2 screen_size;
    vec2 sun_screen_position;
    float sun_dot;
} params;


void main () {
    ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);
    vec2 size = params.screen_size;


    if(pixel.x >= size.x || pixel.y >= size.y) return;

    vec4 screen_texture = imageLoad(screen_image, pixel);
    float occlusion = imageLoad(screen_image, ivec2(params.sun_screen_position)).a;

    float flare = 0.0;

    int samples = 8;

    float campled_dot = clamp(params.sun_dot, 0.0, 1.0);
    float flare_intensity = clamp(1.0 - sin(campled_dot * 3.14), 0.0, 1.0);

    for(int i = 0; i < samples; i++){
        float factor = float(i + 1) / float(samples + 1);
        vec2 uv = pixel / size;
        vec2 p = params.sun_screen_position / size;
        uv -= p;
        uv += (p - vec2(0.5)) * factor * 2.0 * sin(factor * 2.0);
        uv *= 10.0 - sin(factor * 20.0) * (factor) * 5.0;
        uv += (p - vec2(0.5)) * factor * 2.0;
        uv.x *= size.x / size.y;
        uv += 0.5;
        flare += texture(lens_flare_tex, uv).r * flare_intensity;
    }

    vec2 uv = pixel / size;
    vec2 p = params.sun_screen_position / size;
    uv -= p;
    uv *= 3.0 - flare_intensity * 1;
    uv.x *= size.x / size.y;
    uv += 0.5;
    flare += texture(core_lens_flare_tex, uv).r * flare_intensity;

    flare *= (1.0 - occlusion);

    screen_texture.rgb += screen_texture.rgb * screen_texture.rgb * 2.0 * flare + flare * vec3(1.0, 0.8, 0.0) * 0.05;
    imageStore(screen_image, pixel, screen_texture);
}
