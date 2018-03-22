// https://www.shadertoy.com/view/4syyzw
const float pi = 3.1415926535897932384626433832795;

vec2 cmul( vec2 a,  vec2 b ) { return vec2( a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x ); }
vec2 cexpj( vec2 z ) { return exp(-z.y) * vec2(cos(z.x), sin(z.x)); }

vec3 hsv2rgb(in vec3 c)
{
	return c.z*mix(vec3(1.0),0.5+0.5*sin(c.x+vec3(0.0,1.0,2.0)*pi/3.0),c.y);
}

vec3 getcol(float a)
{
	vec3 c = sin(2.0*pi*vec3(a, a + 0.333, a + 0.666)) * 0.5 + 0.5;
    c += 0.01;
    return c * 0.05;
}

vec4 collatz(vec4 z, vec2 shift)
{
    vec2 k = cexpj(pi*z.xy);
    vec2 zd = z.xy*1.25+vec2(0.5,0.0);
    return vec4(
          z.xy*1.75+vec2(0.5,0.0) - cmul(k,zd) + shift,
         cmul(z.zw,vec2(1.75,0.0) - cmul(k,zd*pi-vec2(0.0,1.25)))
    );
}

void main(void)
{
    vec2 p = 7.0*(fragCoord.xy-iResolution.xy*0.5)/iResolution.x;
    vec4 z = vec4(p,1.0,0.0);
    vec2 shift = 1.0 - 2.0 * iMouse.xy / iResolution.xy;
    if (iMouse.xy == iMouse.zw) shift += sin(iGlobalTime + vec2(0.0,pi*0.5));
    for (int i = 0; i < 18; i++)
    {
        z = collatz(z, shift);
    }
    float hue = atan(z.z,z.w);
    float val = 1.0/(1.0+0.0000000000001*dot(z.xy,z.xy));
    float sat = 1.0-1.0/(1.0+0.000000001*dot(z.zw,z.zw));
	fragColor = vec4(hsv2rgb(vec3(hue+iGlobalTime,sat,val)),1.0);
    //fragColor = vec4(pow(getcol(hue),vec3(val)),1.0);
}
