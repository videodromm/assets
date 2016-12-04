// https://www.shadertoy.com/view/MljSzW
// Created by Stefan Draganov - vortex/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

const float s= 8.0;

vec3 n(vec2 x,float t)
{
    vec3 u=floor(vec3(x,t));
    
    vec3 c=fract(
        u.xyz*(vec3(0.16462,0.84787,0.98273)+
         u.xyz*vec3(0.24808,0.75905,0.13898)+
         u.yzx*vec3(0.31517,0.62703,0.26063)+
         u.zxy*vec3(0.47127,0.58568,0.37244))+
        
        u.yzx*(vec3(0.35425,0.65187,0.12423)+
         u.yzx*vec3(0.95238,0.93187,0.95213)+
         u.zxy*vec3(0.31526,0.62512,0.71837))+
        
        u.zxy*(vec3(0.95213,0.13841,0.16479)+
         u.zxy*vec3(0.47626,0.69257,0.19738))
    );
    
    return u+c;
}

vec3 col(vec2 x,float t)
{
    return vec3(0.5)+0.5*cos(fract(vec3(x,t))*371.0241);
}

vec2 idx(vec2 x)
{
    return 
        //clamp(floor(3.0*normalize(vec2(x.y,-x.x))),vec2(-1.0),vec2(1.0));
                       floor(fract(x*29.0)*3.0)-vec2(1.0);
}

float circle(vec2 x,vec2 c,float r)
{
    return max(0.0,1.0-dot(x-c,x-c)/(r*r));
}

void main( void )
{
	vec2 x = s*(gl_FragCoord.xy-1.0*iMouse.xy)/iResolution.x;
    
    float t=iGlobalTime*0.1;
    
    vec4 c=vec4(vec3(0.0),0.1);
    int l;
    for (l=0;   l<1; l++) {
        for (int k=-1; k<=0; k++) {
            for (int i=-1; i<=1; i++) {
                for (int j=-1; j<=1; j++)
                {
                    vec2 X=x+vec2(j,i);
                    float t=t+float(l)*38.0;
                    float T=t+float(k);
                    vec3 a=n(X,T);
                    
                    vec2 o=idx(a.xy);
                    vec3 b=  n(X+o,T+1.0);
                    vec2 m=mix(a.xy,b.xy,(t-a.z)/(b.z-a.z));
                    
                    float r=0.4*sin(3.1415927*clamp((t-a.z)/(b.z-a.z),0.0,1.0));
                    
                    if (length(a.xy-b.xy)/(b.z-a.z)>2.0) r=0.0;
                    
                    c+=vec4(col(a.xy,a.z),
                            1.0)*circle(x,m,r);
                }
            }
        }
    }
	gl_FragColor = vec4(c.rgb/max(1e-5,c.w)+vec3(0.0,0.0,0.5),1.0);
}