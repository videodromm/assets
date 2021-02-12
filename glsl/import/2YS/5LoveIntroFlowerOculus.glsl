// https://www.shadertoy.com/view/Mdf3Wl
void main(void)
{
   vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy;
   uv.x -= iRenderXY.x;
   uv.y -= iRenderXY.y;
	//float ttime = iTime*(iRotationSpeed+1.0);
	uv /= 2.0;
	uv.y -= 0.25;
	float eye_offset = sign(uv.x) * 0.6;
	if(uv.x < 0.0) {
		uv.x = (0.25 + uv.x) * 2.0;
	} else {
		uv.x = (uv.x - 0.25) * 2.0;
	}
	vec2 p = uv * abs(sin(iTime/100.0)) * iRatio;
	float 
		d = sin(length(p)+iTime), 
		a = sin(mod(atan(p.y, p.x) + iTime + sin(d+iTime), 3.1416/3.)*3./eye_offset), 
		v = a + d, 
		m = sin(length(p)*4.0-a+iTime);
	
 	gl_FragColor = vec4(vec3(-v*sin(m*sin(-d)+iTime*.1), v*m*sin(tan(sin(-a))*sin(-a*3.)*3.+iTime*.5), mod(v,m)),1.0);
}