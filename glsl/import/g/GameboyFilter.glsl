// https://www.shadertoy.com/view/4lXGR4
vec3 palette[4];
float palgray[4];
vec3 lum = vec3(0.2126,0.7152,0.0722);

void main(void)
{
    palette[0] = vec3(15,56,15)/256.0;
    palette[1] = vec3(48,98,48)/256.0;
    palette[2] = vec3(140,173,15)/256.0;
    palette[3] = vec3(156,189,15)/256.0;
    for (int i = 0; i < 4; ++i)
        palgray[i] = dot(palette[i], lum);
    for (int i = 0; i < 4; ++i)
        palgray[i] /= palgray[3];
    
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    uv = uv - mod(uv, 0.01);
    
    float gray = dot(texture2D(iChannel0, uv.xy).rgb, lum);
    vec3 color;
    for (int i = 0; i < 4; ++i) {
        if (gray <= palgray[i]) {
            color = palette[i];
            break;
        }
    }
    
    gl_FragColor = vec4(color, 1);
}