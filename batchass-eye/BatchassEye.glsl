// eye (Flopine Revision 2021)
#define PI acos(-1.0)
#define dt(sp) fract(iTime*sp)

mat2 rotate(float a)
{
    float s = sin(a);
    float c = cos(a);
    return mat2(
        c, -s,
        s, c
    );
}
float box(vec3 p, vec3 c) {
    return length(max(abs(p)-c,0.));
}
float cyl(vec3 p, float r, float h) {
    return max(length(p.xy)-r,abs(p.z)-h);
}
float sphere(vec3 p, float r) {
    return length(p.xy)-r;
}
float pipe(vec3 p) {
    float c = cyl(p.xzy, 0.2,1e10);
    float per = 2.;
    p.y = mod(p.y,per)-per*0.5;
    c = min(c,cyl(p.xzy,0.25,0.1));
    return c;
}

float sdf(vec3 p) {
    p.y -= iTime*10.;
    vec3 pp = p;
    float d = -cyl(p.xzy, 10., 1e10);
    float per = 15.;
    float id = floor(p.y/per);
    p.y = mod(p.y,per)-per*0.5;
    float a = mod(id,2.)==0.?dt(0.1):-dt(0.1);
    p.xz *=rotate(a*2.*PI+iRotationSpeed);
    d = min(d, abs(p.y)-(-1.+2.*texture(iChannel0,p.xz*0.05+0.5).x)*0.05);
    p = pp;
    //d = min(d,pipe(p));
    return d;
    //return mix(sphere(p,.5), box(p,vec3(0.5)), sin(iTime));
    //return max(-sphere(p,.5), box(p,vec3(0.5)));
}
vec3 gc(vec3 ro, vec3 ta, vec2 uv) {
    vec3 f = normalize(ta-ro);
    vec3 l = normalize(cross(vec3(0.,1.,0.),f));
    vec3 u = normalize(cross(f,l));
    return normalize(f + uv.x*l +uv.y*u);
}
vec3 eye(vec2 pos) {
    //vec2 uv = pos-1.5;
    vec2 uv = -1.0 + 2.0 * pos;

    vec3 ta = vec3( 0.0, 0.0, -3.5 );
    vec3 ro = vec3( 0.001, 10.0, -1. );
    vec3 rd = gc(ro, vec3(0.),uv);
     
    vec3 col             = vec3(0.13,0.1,0.12) - length(uv)*.012;
    float d, shad        = 0.0;
    vec3 p               = ro;
    
    for (int i = 0; i < 64; i++) {
        d = sdf(p);
        if (d< 0.001) {
            shad = i/64.;      
            break;
        }
        p += d*rd;
    }
    
    float t = length(p-ro); 
    col += vec3(shad);
    return col; 
}
void main(void)
{
   vec2 uv = gl_FragCoord.xy / iResolution.xy * 2.0 - 0.5;
   
  gl_FragColor = vec4(eye(uv),1.0);
}


