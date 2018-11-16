// https://www.shadertoy.com/view/4ttGW4
float hash(in vec2 p) {
    float r = dot(p,vec2(12.1,31.7)) + dot(p,vec2(299.5,78.3));

    return fract(sin(r)*4358.545);
}

//From http://iquilezles.org/www/articles/palettes/palettes.htm
vec3 ColorPalette(in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

vec3 color(vec2 p) {
    return ColorPalette(0.55+hash(p)*0.2, 
                        vec3(0.5), vec3(0.5), vec3(1.0), 
                        vec3(0.0, 0.1, 0.2)) * 1.5;
}

void main(void)
{
    vec2 v = iResolution.xy;
    v = (gl_FragCoord.xy  - v*0.5) / max(v.x, v.y) + vec2(0.2, 0.0);
    vec2 a = vec2(length(v), atan(v.y, v.x));
   
    const float pi = 3.1416;
    const float k = 14.0;
    const float w = 4.0;
    const float t = 1.0;
    
    float i = floor(a.x*k);
    float b = texture2D(iChannel0, 
                        vec2(0.0, 
                             mod(float(iTime)-i*4.0, 1.0)) /
                                                      1.0).r;
    a = vec2((i + 0.3 + b*0.35)*(1.0/k), 
             (floor(a.y*(1.0/pi)*(i*w+t)) + 0.5 ) * pi/(i*w+t));
   
    vec3 c = color(vec2(i,a.y));
    
    a = vec2(cos(a.y), sin(a.y)) * a.x;
    
    c *= smoothstep(0.002, 0.0, length(v-a) - 0.02);
    c *= step(0.07, length(v));
    c += vec3(1.0, 1.0, 0.6) * smoothstep(0.002, 0.0, length(v) - 0.03 - b*0.03);
    
    gl_FragColor = vec4(pow(c, vec3(0.5454)), 1.0);
}
