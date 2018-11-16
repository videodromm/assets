// https://www.shadertoy.com/view/4tl3W8

void main(void)
{
    vec4 p = vec4(gl_FragCoord.xy,0.,1.)/iResolution.y - vec4(.9,.5,0,0), c=p-p;
    float t=iTime,r=length(p.xy+=sin(t+sin(t*.8))*.4),a=atan(p.y,p.x);
    for (float i = 0.;i<60.;i++)
        c = c*.98 + (sin(i+vec4(5,3,2,1))*.5+.5)*smoothstep(.99, 1., sin(log(r+i*.05)-t-i+sin(a +=t*.01)));
    gl_FragColor = c*r;
}
