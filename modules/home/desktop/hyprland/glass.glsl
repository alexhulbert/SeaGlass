uniform vec3 bkg;
uniform float glassTint;
const float tolerance = 20.0 / 255.0;

float keyDistance(vec3 c) {
    vec3 d = abs(c - bkg);
    return max(d.r, max(d.g, d.b));
}
float minimumCoverage(vec3 c) {
    vec3 bound = max((c - bkg) / max(1.0 - bkg, vec3(1e-6)),
                     (bkg - c) / max(bkg, vec3(1e-6)));
    return clamp(max(bound.r, max(bound.g, bound.b)), 0.0, 1.0);
}
void windowShader(inout vec4 color) {
    if (color.a <= 0.0 || glassTint >= 1.0) return;
    vec3 c = color.rgb / color.a;
    if (any(lessThan(c, vec3(-1e-6))) || any(greaterThan(c, vec3(1.000001)))) return;
    c = clamp(c, 0.0, 1.0);
    float d = keyDistance(c);
    if (d >= tolerance + 0.5) return;
    float coverage = smoothstep(tolerance, tolerance + 0.5, d);
    float bound = minimumCoverage(c);
    if (d > tolerance && d < 0.12) {
        ivec2 size = textureSize(x_Tex, 0);
        ivec2 pixel = clamp(ivec2(x_TexCoord * vec2(size)), ivec2(0), size - 1);
        bool rgbx = color.a >= 0.999999 && texelFetch(x_Tex, pixel, 0).a < 0.999999;
        const ivec2 offsets[4] = ivec2[4](ivec2(1, 0), ivec2(-1, 0), ivec2(0, 1), ivec2(0, -1));
        bool nearKey = false, nearContent = false;
        for (int i = 0; i < 4; ++i) {
            vec4 p = texelFetch(x_Tex, clamp(pixel + offsets[i], ivec2(0), size - 1), 0);
            if (rgbx) p.a = 1.0;
            float nd = keyDistance(p.a > 1e-6 ? clamp(p.rgb / p.a, 0.0, 1.0) : bkg);
            nearKey = nearKey || nd <= tolerance;
            nearContent = nearContent || nd > 0.12;
        }
        if (nearKey && nearContent) coverage = bound;
    }
    float fade = clamp(x_FadeIn - x_FadeOut, 0.0, 1.0);
    float removed = color.a * min((1.0 - coverage) * (1.0 - clamp(glassTint, 0.0, 1.0)) * fade, 1.0 - bound);
    color -= removed * vec4(bkg, 1.0);
}
