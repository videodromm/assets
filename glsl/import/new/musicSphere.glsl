// https://www.shadertoy.com/view/lldGzl


#define MAXSTEP 200.
#define FAR 200.
#define EPS 0.01
#define time iGlobalTime

vec4 SPHERE = vec4(0.,0.,0.,4.);


float displacement(vec3 p,float le)
{   
    float t = .05;
    t = texture2D(iChannel0, vec2(0.33, 0.)).x*0.15;
    p = normalize(p);
    float l = abs(p.x)+abs(p.y)+abs(p.z);
    float d = (texture2D(iChannel0,p.yx*t,le)*abs(p.x)+texture2D(iChannel0,p.zx*t,le)*abs(p.y)+
               texture2D(iChannel0,p.xy*t,le)*abs(p.z)).x/(l);
    
    return d*0.5-0.5;
}

float map(vec3 p)
{   
    float t = texture2D(iChannel0, vec2(0.0, 0.)).x;
    float r = SPHERE.w + displacement(p,1.)*t*8.;
    float d = length(p)-r;
    return d;
}
float count = 0.;
float raymarch(vec3 ro,vec3 rd)
{
    float t = 0.;
    vec3 p ;
    for(float i = 0.;i < MAXSTEP;i++)
    {
        p = ro+rd*t;
        float d = map(p);
        if(abs(d) < EPS || t > FAR) break;
        t += d*.1;
        
        count += 1./(1.+d*d);
    }
    return t;
}

vec3 getNormal(vec3 p)
{
    float d = map(p);
    vec2 delta = vec2(EPS,0.);
    return normalize(
        vec3(
            map(p+vec3(delta.xyy))-d,
            map(p+vec3(delta.yxy))-d,
            map(p+vec3(delta.yyx))-d
        )
    );
}
vec3 render(vec3 ro,vec3 rd)
{
    vec3 lig = normalize(vec3(100.,120.,100.));
    vec3 color = vec3(0.);
    vec3 glow = vec3(.20,0.52,0.2);
    float d = raymarch(ro,rd);
    if(d < FAR)
    {
        vec3 p = ro+rd*d;
    
        vec3 n = getNormal(p);
        vec3 amb = vec3(0.2);
        float dif = clamp(dot(n,lig),0.,1.);
        float spe = clamp(dot(normalize(reflect(rd,n)),lig),0.,1.);
        spe = pow(spe,10.);
        
        vec3 f = clamp(dif*vec3(1.)*0.+amb*1.,0.,1.);
        vec3 mat = vec3(.20,0.52,0.2)*f + +.1*spe*vec3(1.);                  
        color = mat;
        
        float l = 1./length(p)*15.2;
        color = color*l;
    }else{
        
        color = glow*exp(-1./(1.+count)*10.1);
    } 
    
    return color;
}

mat3 setCamera(vec3 ro,vec3 tar,float a)
{
    vec3 z = normalize(tar-ro);
    vec3 y = vec3(sin(a),cos(a),0.);
    vec3 x = normalize(cross(y,z));
    y = normalize(cross(z,x));
    return mat3(-x,y,z);
}

void main(void) {   
    vec2 uv = -1.0 + 2.0*gl_FragCoord.xy / iResolution.xy;
       float r = 10.;
    vec3 ro = vec3(sin(time*1.)*r,0.,cos(time*1.)*r);
    vec3 rd = vec3(uv,2.);
    vec3 tar = vec3(0.);
    
    rd = setCamera(ro,tar,0.)*normalize(rd);
    
    vec3 color = vec3(0.);
    color = render(ro,rd);
    
    gl_FragColor = vec4(color,1.0);
}
