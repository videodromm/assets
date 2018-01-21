// https://www.shadertoy.com/view/lsj3Wy
#define YTEPI 3.14159265358979323846

float YTEhash(float x)
{
    return fract(sin(x) * 43758.5453) * 2.0 - 1.0;
}
vec2 YTEhashPosition(float x)
{
	return vec2(YTEhash(x), YTEhash(x * 1.1))*2.0-1.0;
}

bool YTExor(bool a, bool b) {
	return (a && !b) || (!a && b);
}
float YTEcheckerBoardPattern(vec2 p) { // p in [0,1]x[0,1]
	bool x = p.x<0.5;
	bool y = p.y<0.5;
	return ( YTExor(x,y) ) ? 1.:0.;
}

float YTEstripes(vec2 p) {
	float aa = 0.02;
	float xVal = + smoothstep(0.0-aa, 0.0+aa, p.x)
		         + (1.0 - smoothstep(0.5-aa, 0.5+aa, p.x))
		         + smoothstep(1.0-aa, 1.0+aa, p.x);
	return xVal-1.0;
}

void main(void)
{
   vec2 uv = 2.0 * iZoom * (gl_FragCoord.xy/iResolution.xy- 0.5);
//	vec2 r = iZoom * (gl_FragCoord.xy - 0.5*iResolution.xy) / iResolution.y;
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;	
	// move the center around
	uv += vec2(0.35,0.0)*sin(0.92*sin(2.1*iGlobalTime)+0.2);
	uv += vec2(0.0,0.5)*cos(0.45*iGlobalTime+0.3);	

	// polar coordinates
	float mag = length(uv);
	float angle = atan(uv.y,uv.x)/YTEPI;

	float side = 1.0;
	float val = 0.0;
	if(iSteps == 16) {
		vec2 tunnel = vec2(0.3/mag, angle);
		tunnel += vec2(2.5*iGlobalTime, 0.0);//forward speed and angular speed		
		val = YTEstripes(mod(tunnel, side));
	} else if(iSteps < 16) {
		vec2 tunnel = vec2(0.8/mag, 5.*angle+2.*mag);
		tunnel += vec2(2.5*iGlobalTime,0.2*iGlobalTime);		
		val = YTEcheckerBoardPattern(mod(tunnel, side));
	} else if (iSteps > 16) {
		vec2 tunnel = vec2(0.3/mag, 2.*angle);
		tunnel += vec2(2.5*iGlobalTime,0.2*iGlobalTime);		
		val = texture2D(iChannel0, tunnel*1.0).x;
	}
	// yellow and black colors
	vec3 color = mix(vec3(1.0,1.0,0.0), vec3(0.0,0.0,0.0), val);
	
	// the light ring that goes into the tunnel
	float signalDepth = pow(mod(1.5 - 0.9*iGlobalTime, 4.0),2.0);
	float s1 = signalDepth*0.9;
	float s2 = signalDepth*1.1;
	float dd = 0.05;
	color += 0.5*smoothstep(s1-dd,s1+dd, mag)*(1.0-smoothstep(s2-dd,s2+dd,mag))*vec3(1.0,1.0,0.5);
	
	color -= (1.0-smoothstep(0.0, 0.2, mag)); // shadow at the end of the tunnel
	color *= smoothstep( 1.8, 0.15, mag ); // vignette
	gl_FragColor = vec4(color, 1.0);
}

