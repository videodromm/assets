// https://www.shadertoy.com/view/MdKczh
// Code by Flopine
// Thanks to wsmind, leon and lsdlive for teaching me ! :)


#define ITER 80.
#define PI 3.141592

mat2 rot(float a)
{
    float c = cos(a);
    float s = sin(a);
    return mat2(c,s,-s,c);
}

vec2 moda (vec2 p, float per)
{
    float a = atan(p.y,p.x);
    float l = length(p);
    a = mod(a,per)-per/2.;
    return vec2(cos(a),sin(a))*l;
}

// iq's palette
vec3 palette(float t,vec3 a, vec3 b, vec3 c, vec3 d)
{
	return a+b*cos(2.*PI*(c*t+d));    
}

float sc (vec3 p, float s)
{
 p = abs(p);
    p = max(p,p.yzx);
    return min(p.x,min(p.y,p.z))-s;
}

float box (vec3 p, vec3 c)
{
    return length(max(abs(p)-c,0.));
}

float cyl (vec2 p, float r)
{
	return length(p)-r;    
}

float sphe (vec3 p, float r)
{
    return length(p)-r;
}

float wcube (vec3 p, float s)
{
    return max(-sc(p,s), box(p, vec3(s+0.09)));
}

float prim1 (vec3 p, float per)
{
    p.xz *= rot(p.y);
    p.y = mod(p.y-per/2.,per)-per/2.;
    
    return wcube(p,.3);
}

float prim2 (vec3 p, float per)
{
    float c = cyl(p.xz,0.1);
    p.y -= tan(iTime);
    p.y = mod(p.y-per/2.,per)-per/2.;

    float s = sphe(p, 0.2);
    return min(c,s);
}

float elevators (vec3 p, float per)
{
    p.z = mod(p.z-per/2.,per)-per/2.;
    p.xz = moda(p.xz, (2.*PI)/4.);
    p.x -= sin(iTime)+3.;
    return min(prim1(p,0.7),prim2(p,0.8));
}

float hex (vec3 p, float per)
 {
     p.z = mod(p.z-per/2.,per)-per/2.;
     p.xy *= rot(iTime);
    p.xy = moda(p.xy, (2.*PI)/6.);
    p.x -= 2.;
    return min(prim1(p,0.7),prim2(p,0.8));
} 


float SDF (vec3 p)
{

    return min(elevators(p,6.), hex(p,3.));
}
void main(void)
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = 2.*(fragCoord.xy/iResolution.xy)-1.;
	uv.x *= iResolution.x/iResolution.y;
    
    vec3 p = vec3(0.001,.001,iTime*0.5);
    vec3 dir = normalize(vec3(uv,1.));
    
    float shad = 0.;
    vec3 col = vec3(0.);
    for (float i = 0.; i<ITER; i++)
    {
        float d = SDF(p);
        if (d<0.001)
        {shad = i/ITER;
         col = vec3(1.-shad)*palette(p.z*2.,
                                    vec3(0.,0.3,0.7),
                                    vec3(0.2,0.3,0.3),
                                    vec3(.2),
                                    vec3 (0.,0.2,iTime*0.5));
         break;
        }
        else col = palette(length(uv),
                          vec3 (0.,0.1,0.7),
                           vec3(0.,0.5,0.3),
                           vec3 (0.3),
                           vec3(0.5));
        p += d*dir*0.7;
    }

    // Output to screen
    fragColor = vec4(pow(col, vec3(0.45)),1.0);
}
 