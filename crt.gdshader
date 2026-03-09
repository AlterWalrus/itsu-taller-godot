shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float fisheye_strength = 1.0; // Adjust this to control the fisheye effect strength
uniform float curve_intensity = 1.0; // Adjust this to control the curve intensity
uniform float color_distortion = 1.0; // Adjust this to control the color distortion
uniform float color_tint = 1.0; // Adjust this to control the color tint
uniform float scanline_intensity = 1.0; // Adjust this to control the scanline intensity
uniform float screen_flicker = 1.0; // Adjust this to control the screen flicker
uniform float screen_distortion = 1.0; // Adjust this to control the screen distortion

// Apply fisheye distortion
vec2 fisheye(vec2 uv) {
    vec2 d = uv - 0.5;
    float r = length(d);
    //float theta = atan(d.y, d.x);
    float rf = pow(r, fisheye_strength) / pow(0.5, fisheye_strength - 1.0);
    return vec2(0.5) + rf * normalize(d);
}

// Apply screen curvature
vec2 curve(vec2 uv) {
    uv = (uv - 0.5) * 2.0;
    uv *= 1.1;
    uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0) * curve_intensity;
    uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0) * curve_intensity;
    uv = (uv / 2.0) + 0.5;
    uv = uv * 0.92 + 0.04;
    return uv;
}

void fragment() {
    vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 q = FRAGCOORD.xy / iResolution.xy;

    // Apply fisheye distortion
    q = fisheye(q);

    // Apply screen curvature
    vec2 uv = curve(q);
    uv = curve(uv);

    // Sample the screen texture
    //vec3 oricol = texture(screen_texture, vec2(q.x, q.y)).xyz;
    vec3 col;

    // Apply color distortion
    float x = sin(0.3 * TIME + uv.y * 21.0) * sin(0.7 * TIME + uv.y * 29.0) * sin(0.3 + 0.33 * TIME + uv.y * 31.0) * 0.0017 * color_distortion;
    col.r = texture(screen_texture, vec2(x + uv.x + 0.001, uv.y + 0.001)).x + 0.05;
    col.g = texture(screen_texture, vec2(x + uv.x + 0.000, uv.y - 0.002)).y + 0.05;
    col.b = texture(screen_texture, vec2(x + uv.x - 0.001, uv.y + 0.000)).z + 0.05;
    col.r += 0.08 * texture(screen_texture, 0.75 * vec2(x + 0.025, -0.027) + vec2(uv.x + 0.001, uv.y + 0.001)).x;
    col.g += 0.05 * texture(screen_texture, 0.75 * vec2(x + -0.022, -0.02) + vec2(uv.x + 0.000, uv.y - 0.002)).y;
    col.b += 0.08 * texture(screen_texture, 0.75 * vec2(x + -0.02, -0.018) + vec2(uv.x - 0.002, uv.y + 0.000)).z;

    // Apply color correction
    col = clamp(col * 0.6 + 0.4 * col * col * 1.0, 0.0, 1.0);

    // Apply color tint
    col *= vec3(0.95 + (color_tint - 1.0) * 0.05, 1.05 + (color_tint - 1.0) * 0.05, 0.95 + (color_tint - 1.0) * 0.05);

    // Apply vignette
    float vig = (0.0 + 1.0 * 16.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y));
    col *= vec3(pow(vig, 0.3));

    // Apply scanline effect
    float scans = clamp(0.35 + 0.35 * sin(3.5 * TIME + uv.y * iResolution.y * 1.5), 0.0, 1.0);
    float s = pow(scans, 1.7);
    col = col * vec3(0.4 + 0.7 * s * scanline_intensity);

    // Apply screen flicker
    col *= 1.0 + 0.01 * sin(110.0 * TIME * screen_flicker);

    // Clamp the output to the screen bounds
    if (uv.x < 0.0 || uv.x > 1.0)
        col *= 0.0;
    if (uv.y < 0.0 || uv.y > 1.0)
        col *= 0.0;

    // Apply screen distortion
    col *= 1.0 - 0.65 * vec3(clamp((mod(FRAGCOORD.x, 2.0) - 1.0) * 2.0, 0.0, 1.0) * screen_distortion);

    // Blend the final result
    COLOR = vec4(col, 1.0);
}