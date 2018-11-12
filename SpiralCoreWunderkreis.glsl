// https://www.shadertoy.com/view/XdlBzr
vec2 frame(vec2 u){
	u=u/iResolution.xy;u-=.5;
 u.x*=iResolution.x/iResolution.y;
 return u;}
//golden angle ratio, to avoid interferrences of periods over time.
#define phi (sqrt(5.)*.5-.5)

#define time iGlobalTime
#define time1 (sin(time       )*.5+.5)
#define time2 (sin(time*phi*2.)*.5+.5)

#define snoothness time1*.5

#define zoom (100.*time1+9.)

//return triangle wave amp=1 period=1.
float wTri(float x){x=fract(x);//get seesaw wave
 return abs(x*2.-1.);}//seesaw to triangle wave

//return brightness of ripple of in distance [d] with [n] ripples within [r]
float ripple(float d,float n,float r){
 d+=1.5;
 d=min(r,d);
 d=wTri(d);
 d=smoothstep(.5+snoothness,.5-snoothness,d);
 return d;}

void main(void)
{
 vec2 u=frame(fragCoord.xy);
 u*=zoom;
 vec2 m=frame(iMouse.xy);
 float o=floor(-m.x    *zoom);
 float r=floor(1.-(m.y-.5)*zoom);
 float d;
 if (u.y>0.)d=ripple(length(u)   ,1.,r);
 else       d=ripple(length(u+vec2(o,0)),1.,r);
 //d.z+=mix(d.x,0.,time2);
 fragColor=vec4(vec3(d),1);
 }
