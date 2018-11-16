#define TRAN0 vec4(0.0, 0.0, 0.0, 0.0)

float beat = 0.;
const float TIME_TRAN = 0.4;	// Transition time
const float TIME_INTR = 0.1;	// Intermission between in/out
const float TIME_PADN = 0.1;	// Padding time at the end of out.
const float TIME_TOTAL = (2.0 * TIME_TRAN) + TIME_INTR + TIME_PADN;

void main(void)
{
	float ct = iTime/iRatio;
	if ((ct > 8.0 && ct < 33.5)
	|| (ct > 38.0 && ct < 88.5)
	|| (ct > 93.0 && ct < 194.5))
		beat = pow(sin(ct*3.1416*3.78+1.9)*0.5+0.5,15.0)*0.1;
	
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
	vec2 p=(2.0*gl_FragCoord.xy-iResolution.xy)/max(iResolution.x,iResolution.y);
	
	for(int i=1;i<40;i++)
	{
		vec2 newp=p;
		newp.x+=0.5/float(i)*cos(float(i)*p.y+beat+iTime*cos(ct)*0.3/40.0+0.03*float(i))+10.0;		
		newp.y+=0.5/float(i)*cos(float(i)*p.x+beat+iTime*ct*0.3/50.0+0.03*float(i+10))+15.0;
		p=newp;
	}
	
	vec4 col=vec4(0.5*sin(3.0*p.x)+0.5,0.5*sin(3.0*p.y)+0.5,sin(p.x+p.y),1.0);
	gl_FragColor=col;
	
}