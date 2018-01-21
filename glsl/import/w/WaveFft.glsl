// https://www.shadertoy.com/view/Xls3RN
// Iain Melvin 2014

// gradient from: https://www.shadertoy.com/view/4dsSzr

#define REFLECT 


vec3 heatmapGradient(float t) {
    return clamp((pow(t, 1.5) * 0.8 + 0.2) * vec3(smoothstep(0.4, 0.00005, t) + t * 0.5, smoothstep(0.5, 1.0, t), max(1.0 - t * 1.7, t * 7.0 - 6.0)), 0.0, 1.0);
}

void main(void)
{
    // create pixel coordinates
    vec2 uv = gl_FragCoord.xy / iResolution.xy;

#ifdef REFLECT
    uv=abs(2.0*(uv-0.5));
#endif
    
    // 0.25 = fft 0.75 = wave
    float wave1 = texture2D(iChannel0, vec2(uv.y, 0.75)).x;
    float wave2 = texture2D(iChannel0, vec2(uv.x, 0.75)).x;
    float wave= wave1 * wave2;
    
    float a = abs(wave-sqrt(uv.y*uv.y+uv.x*uv.x));
    a=a*2.0;
    gl_FragColor = vec4( heatmapGradient(1.0-a),1.0);
}