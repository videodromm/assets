// https://www.shadertoy.com/view/Ml2GRD

float divisions = 2.;
float modulationDepth = 2.;

vec4 gradient(float f)
{
    vec4 c = vec4(0);
	f = mod(f, 1.5);
    for (int i = 0; i < 3; ++i)
        c[i] = pow(.5 + .5 * tan(2.0 * (f +  .2*float(i))), 10.0);
    return c;
}

float offset(float th)
{
    return modulationDepth * sin(divisions * th)*sin(iGlobalTime);
}

vec4 tunnel(float th, float radius)
{
	return gradient(offset(th + .25*iGlobalTime) + 3.*log(3.*radius) - iGlobalTime);
}

void main( void )
{
    vec2 p = -0.5 + gl_FragCoord.xy / iResolution.xy;
    p.x *= iResolution.x/iResolution.y;
	fragColor = tunnel(atan(p.y, p.x), length(p));
}