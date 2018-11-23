// https://www.shadertoy.com/view/Ml3cDS

void main(void)
{  
    vec2 u=iZoom * abs(gl_FragCoord.xy/iResolution.xy-.5);
    u.x*=3.;

	fragColor = vec4(mix( 
        .3-.3*pow(u.x/length(u),5.), 
        step(.5,fract(sin(dot(floor(vec2(2./u.x,iSteps/u.x*u.y)),vec2(12.13,4.47)))+iTime)),
        u.x>u.y
    )*max(u.x,u.y)*2.);
}
