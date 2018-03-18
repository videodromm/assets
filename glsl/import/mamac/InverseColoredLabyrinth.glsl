// https://www.shadertoy.com/view/XlGXDc
float rand(vec2 v)
{
    return fract(sin(dot(v,vec2(12.9898,78.233)))*43758.5453);
}
void main(void)
{
  	vec2 uv = gl_FragCoord.xy / iResolution.y;
    uv = uv*2.-1.;
    uv.x*=iResolution.x/iResolution.y;
    uv+=iGlobalTime*.03;

    //float t = 8.*iMouse.x/iResolution.x;
    float t = 8./iResolution.x;
    
    vec2 uz = uv*(2.+t);
    float r = rand(floor(uz));
    
    vec2 f1 = fract(uz);
    if(r<.5){f1.x = 1.-f1.x;}
    vec2 f2 = 1.-f1;
    float c1 = .001/abs(dot(f1,f1)-.25)+
        	   .001/abs(dot(f2,f2)-.25);
    
    f1 = fract(uz+.5);
    if(r<.5){f1.x = 1.-f1.x;}
    f2 = 1.-f1;
    c1 -= .01/abs(dot(f1,f1)-.25)+
          .01/abs(dot(f2,f2)-.25);
    
    vec4 cch = sin(iGlobalTime*vec4(.1,.2,.3,0.));
    
	fragColor = abs(.5-c1*cch);
}
