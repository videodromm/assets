// https://www.shadertoy.com/view/MsKyRh
mat2 r2d(float a){
    float c=cos(a),s=sin(a);
    return mat2(c,s,-s,c);
}

void amod(inout vec2 p, float m) {
    float a = mod(atan(p.x,p.y)-m*.5,m) - m*.5;
    p = vec2(cos(a),sin(a)) * length(p);
}

float sc(vec3 p){
    p=abs(p);
    p=max(p,p.yzx);
    return min(p.x,min(p.y,p.z)) - .2;
}

void mo(inout vec2 p, vec2 d) {
    p.y = abs(p.y) - d.x;
    p.x = abs(p.x) - d.y;
    if(p.y>p.x) p.xy=p.yx;
}

float g=0.;
float de(vec3 p) {
    vec3 q = p;
    q.x += sin(q.z)*.4;
    float s = length(mod(q+iTime+vec2(0,sin(iTime*.2)*4.).yxx-1., 2.)-1.) - .04 - sin(iTime*30.)*.003;
    
    p.xy*=r2d(-3.14*.25);
    p.zy*=r2d(3.14*.03);
    
    p.xz*=r2d(iTime);
    p.y-=length(p.xz)*.3;
    
	amod(p.xz, .785);
    
    mo(p.xz, vec2(.33, .05));
    
    float s2 = length(p.yz) -.28;
    
    float d = sc(p);
    d = min(d,s);
    d = min(d,s2);
    g+=.01/(.01+d*d);
	return d;
}
void main(void)
{
    vec2 uv = fragCoord.xy/iResolution.xy-.5;
    uv.x*=iResolution.x/iResolution.y;
    vec3 ro=vec3(1,1,-3.5);
    vec3 rd=normalize(vec3(uv, 1));

    vec3 p;
    float t=0.,ri;
    for(float i=0.;i<1.;i+=.01){
        ri=i;
    	p=ro+rd*t;
        float d=de(p);
        if(d<.01)break;
        t+=d*.5;
    }

    vec3 bg = vec3(.2, .18, .27);
    vec3 col = mix(vec3(.9, .2, .3), bg, ri);
    col+=g*.05;
    
    col = mix(col, bg, 1.-exp(-.01*t*t));
    fragColor = vec4(col,1.0);
}

