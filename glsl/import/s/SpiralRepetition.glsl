// https://www.shadertoy.com/view/XdfGzj
const int STEPS = 96;
const float EPSILON = 0.01;
const float FAR = 70.0;
const float AO_STEPS = 5.0;
const float AO_DIST = 1.5;
const float PI = 3.14159265358979323846264;

float noise(vec2 uv)
{
    return fract(sin(dot(uv ,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 schlick(vec3 f0, vec3 h, vec3 v)
{
    return f0 + (1.0 - f0) * pow(1.0 - dot(h,v), 5.0);
}

vec3 sampleHemi(float u1, float u2, vec3 n)
{
    vec3 v = abs(n.y) < abs(n.z) ? vec3(0.0,1.0,0.0) : vec3(0.0,0.0,1.0);
    vec3 w = normalize(cross(n,v));
    v = normalize(cross(w,n));
    
    float r = sqrt(u1);
    float theta = 2.0 * PI * u2;
    float x = r * cos(theta);
    float y = r * sin(theta);
    return normalize(n * sqrt(1.0 - u1) + v*x + w*y);
}

vec3 rotateX(vec3 pt, float theta)
{
    return vec3(pt.x, cos(theta)*pt.y + sin(theta)*pt.z, cos(theta)*pt.z - sin(theta)*pt.y);
}

vec3 rotateY(vec3 pt, float theta)
{
    return vec3(cos(theta)*pt.x + sin(theta)*pt.z, pt.y, cos(theta)*pt.z - sin(theta)*pt.x);
}

float d_plane(vec3 pt, vec4 pln)
{
    return dot(pt, pln.xyz) - pln.w;
}

float d_sphere(vec3 pt, vec4 sph)
{
    return length(pt - sph.xyz) - sph.w;
}

float d_spiral(vec3 pt)
{
    pt.x += sin(pt.y) * cos(iGlobalTime);
    pt.z += cos(pt.y) * sin(iGlobalTime);
    pt = rotateY(pt,pt.y);
    return length(pt.xz) - 1.5*(2.0 + cos(iGlobalTime));
}

float dist(vec3 pt)
{
    float d0 = d_plane(pt, vec4(0.0,1.0,0.0,-3.0));
    
    vec3 pt2 = vec3(mod(pt.x,14.0)-7.0,pt.y,mod(pt.z,14.0)-7.0);
    float d1 = d_sphere(pt2, vec4(0.0,0.0,0.0,4.0));
    pt2 = rotateY(pt2,iGlobalTime);
    float d2 = d_spiral(pt2);
    d2 += sin(2.0*pt2.x)*cos(2.0*pt2.y)*sin(cos(iGlobalTime*4.0)*pt2.z)*0.5;
    float t = 1.0 - exp(-pt.y/4.0);
    return min(d0,mix(d1,d2,t));
}

vec3 calc_normal(vec3 pos)
{
    vec3 res;
    res.x = dist(pos + vec3(EPSILON,0.0,0.0)) - dist(pos - vec3(EPSILON,0.0,0.0));
    res.y = dist(pos + vec3(0.0,EPSILON,0.0)) - dist(pos - vec3(0.0,EPSILON,0.0));
    res.z = dist(pos + vec3(0.0,0.0,EPSILON)) - dist(pos - vec3(0.0,0.0,EPSILON));
    return normalize(res);
}

vec4 march(vec3 ro, vec3 rd)
{
    float t = 0.0;
    for (int i=0; i<STEPS; i++)
    {
        vec3 pt = ro + rd * t;
        float d = dist(pt);
        if (abs(d) < EPSILON)
            return vec4(pt,1.0);
        t += d;
        if (t >= FAR)
            break;
    }
    return vec4(0.0);
}

float calc_ao(vec3 p, vec3 n)
{
    float r = 0.0;
    float w = 1.0;
    for (float i=0.0; i<AO_STEPS; i++)
    {
        float d = ((i + 1.0) / AO_STEPS) * AO_DIST;
        r += w * (d - dist(p + n * d));
        w *= 0.5;
    }
    return 1.0 - clamp(r,0.0,1.0);
}

float calc_shadow(vec3 p, vec3 l)
{
    float r = 1.0;
    float t = 0.0;
    for (float i=0.0; i<16.0; i++)
    {
        vec3 pt = p + l * t;
        float d = dist(pt);
        if (d < EPSILON)
            return 0.0;
        
        r = min(r,32.0*d/t);
        t += clamp(d,0.01,4.0);
    }
    return r;
}

vec3 diffuse(vec3 p, vec3 n)
{
    vec3 clr = vec3(0.0);
    vec3 t = vec3(0.0,1.0,0.0);
    if (dot(t,n) < 0.001)
        t = vec3(0.0,0.0,1.0);
    vec3 b = cross(n,t);
    t = normalize(cross(b,n));
    
    for (float i=0.0; i<8.0; i++)
    {
        for (float j=0.0; j<8.0; j++)
        {
            vec2 s = vec2(i,j)*vec2(sin(iGlobalTime))*gl_FragCoord.xy;
            float u = (noise(n.xy+s)+i)*0.125;
            float v = (noise(n.yz+s)+j)*0.125;
            vec3 n0 = sampleHemi(u*0.5,v,n);
            //clr += pow(vec3(texture2D(iChannel1,n0.xy),1.0), vec3(2.2));
            clr += pow(n0, vec3(2.2));
        }
    }
    
    return clr * 0.125 * 0.125;
}

vec3 shade(vec3 pos, vec3 v)
{
    const float spec_power = 128.0;
    float normalization = (spec_power + 2.0) / (2.0 * PI);
    
    vec3 ldir = normalize(vec3(cos(iGlobalTime),1.0,sin(iGlobalTime)));
    vec3 n = calc_normal(pos);
    vec3 h = normalize(n+ldir);
    float ndl = max(dot(n,ldir),0.0);
    float ndh = max(dot(n,h),0.0);
    vec3 fresnel = schlick(vec3(0.05,0.05,0.05),h,v);
    vec3 spec = vec3(pow(ndh, spec_power)) * normalization * ndl * (PI / 4.0);
    vec3 diff = vec3(ndl);
    vec3 lcolor = spec * fresnel + diff;
    float shadow = calc_shadow(pos + n * 0.1, ldir);
    return lcolor*shadow + calc_ao(pos,n) * diffuse(pos,n);
}

void main(void)
{
    vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy;
    uv.x -= iRenderXY.x;
    uv.y -= iRenderXY.y; 
   vec3 rd = normalize(vec3((-1.0 + 2.0 * uv)*vec2(iResolution.x/iResolution.y,1.0), 1.0));
    vec3 ro = vec3(0.0, 4.0, -10.0);
    vec3 forward = vec3(0.0, 0.0, 1.0);
    
    float theta_y = sin(iGlobalTime) * 0.5;
    rd = rotateY(rd, theta_y);
    ro += forward * iGlobalTime * 8.0;
    ro.x = cos(iGlobalTime) * 2.0;
    ro.y = sin(iGlobalTime) * 4.0 + 6.0;
    
    vec4 res = march(ro,rd);
    //if (res.w == 1.0)
    //{
        vec4 clr = vec4(pow(shade(res.xyz,rd), vec3(0.45)), 1.0);
        gl_FragColor = clr;
    /*}
    else
    {
        gl_FragColor = texture2D(iChannel0,rd);
    }*/
}
