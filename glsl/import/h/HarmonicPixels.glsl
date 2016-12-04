const float N_ITERATIONS = 50.0;

float usin(float t) {
	return sin(t) * 0.5 + 0.5;
}

float orb(float x0, float freqMul, float amp, float aspect, vec3 pos, float glow, float ampFreq) {
	float c = 0.0;
	float s = sin(iGlobalTime*ampFreq);
	for (float i = 0.0; i < N_ITERATIONS; i++) {
		float freq = freqMul*(i+1.0)/N_ITERATIONS;
		float x = x0+i/N_ITERATIONS;
		float y = 0.5 + s*sin(freq*iGlobalTime)*amp;
		
		vec3 circPos = vec3(x*aspect, y, 1.0);
		float f = 0.17;
	
		float sinTime = 1.0-usin(iGlobalTime)*0.3;
		float dx = pos.x - circPos.x;
		float dy = pos.y - circPos.y;
		float d = glow*(dx*dx + dy*dy);		
		c += f/(d*50.*sinTime);
	}
	
	return c;
}

vec3 bgColor(vec3 pos) {
	float f = gl_FragCoord.y;	
	vec3 c = vec3(1.0, 1.0, 1.0);
	f = float(mod(f/1.0, 3.0));
	return c*f;
}
void main(void)
{
   vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy;
   uv.x -= iRenderXY.x;
   uv.y -= iRenderXY.y;
	float aspect = iResolution.x / iResolution.y;
	vec3 pos = vec3(uv, 1.0);// * 2.0 - vec2(1.0);
	pos.x -= iRenderXY.x;
	pos.y -= iRenderXY.y;
	pos.x *= aspect;
	
	const float amp = 0.3;
	const float x0 = 0.5/N_ITERATIONS;
	
	float r = orb(x0, 0.3, amp, aspect, pos, 2.5, 0.5);
	float g = orb(x0, 0.6, amp, aspect, pos, 4.5, 0.75);
	float b = orb(x0, 0.9, amp, aspect, pos, 6.5, 0.5);	
	
	float p = usin(iGlobalTime*1.2)*0.5+0.5;
	float q = 1.5 - p;
	vec3 col = vec3(r, q*g, p*b);
	vec3 bg = bgColor(pos);
	col *= bg;
	col *= 1.0 - usin(2.0*iGlobalTime)*0.1;

  gl_FragColor = vec4(col,1.0);
}
