// https://www.shadertoy.com/view/XdjSzD

// noise functions
float Hash2d(vec2 uv)
{
    float f = uv.x + uv.y * 37.0;
    return fract(sin(f)*104003.9);
}
float mixP(float f0, float f1, float a)
{
    return mix(f0, f1, a*a*(3.0-2.0*a));
}
vec2 noise2dTex2(vec2 uv)
{
    vec2 fr = fract(uv);
    vec2 smooth1 = fr*fr*(3.0-2.0*fr);
    vec2 fl = floor(uv);
    uv = smooth1 + fl;
    return texture2D(iChannel0, (uv + 0.5), -100.0).xy;    // use constant here instead?
}

const vec2 zeroOne = vec2(0.0, 1.0);
float noise2d(vec2 uv)
{
    vec2 fr = fract(uv.xy);
    vec2 fl = floor(uv.xy);
    float h00 = Hash2d(fl);
    float h10 = Hash2d(fl + zeroOne.yx);
    float h01 = Hash2d(fl + zeroOne);
    float h11 = Hash2d(fl + zeroOne.yy);
    return mixP(mixP(h00, h10, fr.x), mixP(h01, h11, fr.x), fr.y);
}

float Fractal(vec2 p)
{
    vec2 pr = p;
    float scale = 1.0;
    float iter = 1.0;
    for (int i = 0; i < 12; i++)
    {
        vec2 n2 = noise2dTex2(p*0.15*iter+iGlobalTime*1.925);
        float nx = n2.x - 0.5;
        float ny = n2.y;
        pr += vec2(nx, ny)*0.0002*iter*iter*iter;
        pr = fract(pr*0.5+0.5)*2.0 - 1.0;
        float len = pow(dot(pr, pr), 1.0+nx*0.5);
        float inv = 1.1/len;
        pr *= inv;
        scale *= inv;
        iter += 1.0;
    }
    float b = abs(pr.x)*abs(pr.y)/scale;
    return pow(b, 0.125)*0.95;
}

void main(void)
{
    // center and scale the UV coordinates
	vec2 uv = iZoom * (gl_FragCoord.xy/iResolution.xy-0.5);
	uv.x *= float(iResolution.x )/ float(iResolution.y);

    // do the magic
    vec2 warp = normalize(uv) * (1.0-pow(length(uv), 0.45));
    vec3 finalColor = vec3(Fractal(uv*2.0+1.0),
                           Fractal(uv*2.0+37.0),
                           Fractal((warp+0.5)*2.0+15.0));
    finalColor = 1.0 - finalColor;
    float circle = 1.0-length(uv*2.2);
    float at = atan(uv.x, uv.y);
    float aNoise = noise2d(vec2(at * 30.0, iGlobalTime));
    aNoise = aNoise * 0.5 + 0.5;
    finalColor *= pow(max(0.0, circle), 0.1)*2.0;	// comment out this line to see the whole fractal.
    finalColor *= 1.0 + pow(1.0 - abs(circle), 30.0);	// colorful outer glow
    finalColor += vec3(1.0, 0.3, 0.03)*3.0 * pow(1.0 - abs(circle), 100.0) * aNoise;	// outer circle
    float outer = (1.0 - pow(max(0.0, circle), 0.1)*2.0);
    finalColor += vec3(1.,0.2,0.03)*0.4* max(0.0, outer*(1.0-length(uv)));
    gl_FragColor = vec4(finalColor, 1.0);
}
