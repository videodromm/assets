// https://www.shadertoy.com/view/llsGW7

#define F +texture(iChannel0,.3+p.xz*s/3e3)/(s+=s) 

void main(void)
{
    vec4 p=vec4(gl_FragCoord.xy/iResolution.xy,1,1)-.5,d=p,t;
    p.z += iTime*20.;d.y-=.4;
    for(float i=1.5;i>0.;i-=.002)
    {
        float s=.5;
        t = F F F F F F;
        gl_FragColor =1.+d.x-t*i; gl_FragColor.z-=.1;
        if(t.x>p.y*.007+1.3)break;
        p += d;
    }
}
